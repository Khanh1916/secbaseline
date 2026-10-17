package port

import (
	"fmt"
	"net"
	"slices"
	"strings"

	gopsutilnet "github.com/shirou/gopsutil/v3/net"
)

func socketTypeToString(t uint32) string {
	switch t {
	case 1:
		return "TCP"
	case 2:
		return "UDP"
	default:
		return "UNKNOWN"
	}
}

func GetPorts() (string, error) {
	conns, err := gopsutilnet.Connections("inet")
	if err != nil {
		return "", err
	}

	ports := make([]string, 0)

	for _, conn := range conns {
		if conn.Status == "LISTEN" {
			ip := net.ParseIP(conn.Laddr.IP)
			if ip.IsLoopback() {
				continue
			}
			ipStr := conn.Laddr.IP
			if ip.To4() == nil {
				ipStr = fmt.Sprintf("[%s]", conn.Laddr.IP)
			}

			ports = append(ports, fmt.Sprintf("%s:%d/%s", ipStr, conn.Laddr.Port, socketTypeToString(conn.Type)))
		}
	}
	slices.Sort(ports)
	return strings.Join(ports, "\n"), nil
}
