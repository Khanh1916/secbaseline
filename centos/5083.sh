#!/bin/bash

# Policy (CIS): minlen >= 14 and all four character classes required, either
# with minclass >= 4 or with dcredit, ucredit, lcredit and ocredit all <= -1.
# Settings come from pwquality.conf and pwquality.conf.d/*.conf (when a setting
# appears more than once, the weakest value is used) and are overridden by
# arguments on the pam_pwquality.so line. pam_cracklib.so (SUSE's default)
# takes the same settings from its arguments only. Unset settings use the
# module defaults (minlen 8, minclass 0, credits 0).
MIN_LEN=14
MIN_CLASS=4

PAM_FILES=(
  /etc/pam.d/common-password
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth
)

CONF_FILES=(/dev/null)
for f in /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf; do
  [ -f "$f" ] && CONF_FILES+=("$f")
done

found_pam=0
weak=""
for f in "${PAM_FILES[@]}"; do
  [ -f "$f" ] || continue
  while IFS= read -r line; do
    found_pam=1
    module=${line%%.so*}
    args=${line#*.so}
    confs=("${CONF_FILES[@]}")
    [ "$module" = pam_cracklib ] && confs=(/dev/null)
    result=$(awk -v args="$args" -v min_len="$MIN_LEN" -v min_class="$MIN_CLASS" '
      function weaker(k, v) {
        if (!(k in val)) return 1
        if (k == "minlen" || k == "minclass") return v + 0 < val[k] + 0
        return v + 0 > val[k] + 0
      }
      /^[[:space:]]*(minlen|minclass|dcredit|ucredit|lcredit|ocredit)[[:space:]]*=/ {
        line = $0
        sub(/#.*/, "", line)
        split(line, kv, "=")
        k = kv[1]; gsub(/[[:space:]]/, "", k)
        v = kv[2]; gsub(/[[:space:]]/, "", v)
        if (v ~ /^-?[0-9]+$/ && weaker(k, v)) val[k] = v
      }
      END {
        n = split(args, a, /[[:space:]]+/)
        for (i = 1; i <= n; i++)
          if (a[i] ~ /^(minlen|minclass|dcredit|ucredit|lcredit|ocredit)=-?[0-9]+$/) {
            split(a[i], kv, "=")
            val[kv[1]] = kv[2]
          }
        minlen = ("minlen" in val) ? val["minlen"] + 0 : 8
        classes = ("minclass" in val) ? val["minclass"] + 0 : 0
        required = 0
        split("dcredit ucredit lcredit ocredit", credits, " ")
        for (i = 1; i <= 4; i++)
          if ((credits[i] in val) && val[credits[i]] + 0 <= -1) required++
        if (required > classes) classes = required
        printf "minlen=%d classes=%d %s\n", minlen, classes, (minlen >= min_len && classes >= min_class) ? "ok" : "weak"
      }
    ' "${confs[@]}")
    echo "INFO: $f: $module.so effective $result"
    case "$result" in
      *weak) weak="$weak $f(${result% weak})" ;;
    esac
  done < <(grep -E '^[[:space:]]*-?password[[:space:]].*pam_(pwquality|cracklib)\.so' "$f" |
    sed -E 's/.*(pam_(pwquality|cracklib)\.so)/\1/')
done

if [ $found_pam -eq 0 ]; then
  echo "FAIL: pam_pwquality.so or pam_cracklib.so not found in any PAM password stack"
  exit 1
fi

if [ -n "$weak" ]; then
  echo "FAIL: Password quality must require minlen >= $MIN_LEN and $MIN_CLASS character classes; found:$weak"
  exit 1
fi

echo "PASS: Password quality requires minlen >= $MIN_LEN and $MIN_CLASS character classes"
exit 0
