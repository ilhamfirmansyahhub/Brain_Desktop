import QtQuick
import Quickshell
import "../../components"
import "../../windows"
import "../../"

Row {
	spacing: 5
	// Note: Do NOT add anchors.centerIn: parent here. TopBar handles that.

	// 1. Workspaces
	Workspaces {}
	
	// 2. LayoutDisplay
	LayoutDisplayer {}

}
