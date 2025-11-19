import Testing
import SwifTeaUI
@testable import SwifTeaUI

struct TableTests {
    private struct Package: Identifiable {
        let id: Int
        let name: String
        let version: String
        let status: String
    }

    @Test("Table renders headers, divider, and rows")
    func testBasicRendering() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed"),
            Package(id: 2, name: "Tuist", version: "4.0.0", status: "Outdated")
        ]

        let table = Table(
            packages,
            divider: .line(),
            header: {
                Text("Packages")
            },
            footer: {
                Text("2 total")
            },
            columns: {
                TableColumn(width: .fitContent, alignment: .leading, header: { Text("Package") }) { (item: Package) in
                    Text(item.name)
                }
                TableColumn(width: .fitContent, alignment: .leading, header: { Text("Version") }) { (item: Package) in
                    Text(item.version)
                }
                TableColumn(width: .fitContent, alignment: .leading, header: { Text("Status") }) { (item: Package) in
                    Text(item.status)
                }
            }
        )

        let lines = table.render().split(separator: "\n").map(String.init)
        #expect(lines == [
            "Packages",
            "Package  Version  Status   ",
            "───────────────────────────",
            "Mint     0.17.2   Installed",
            "Tuist    4.0.0    Outdated ",
            "2 total"
        ])
    }

    @Test("Column width rules clamp output as requested")
    func testColumnWidthRules() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed")
        ]

        let table = Table(
            packages,
            columnSpacing: 1,
            divider: .none,
            columns: {
                TableColumn(width: .fixed(10), alignment: .trailing, header: { Text("Name") }) { (item: Package) in
                    Text(item.name)
                }
                TableColumn(width: .flex(min: 5, max: 8), alignment: .center, header: { Text("Ver") }) { (item: Package) in
                    Text(item.version)
                }
            }
        )

        let lines = table.render().split(separator: "\n").map(String.init)
        #expect(lines == [
            "      Name  Ver  ",
            "      Mint 0.17.2"
        ])
    }

    @Test("Row style closure applies ANSI styling per row")
    func testRowStyle() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed"),
            Package(id: 2, name: "Tuist", version: "4.0.0", status: "Outdated")
        ]

        let table = Table(
            packages,
            divider: .none,
            rowStyle: { _, index in
                index == 0 ? TableRowStyle(backgroundColor: .cyan, isBold: true) : nil
            },
            columns: {
                TableColumn(width: .fitContent, alignment: .leading, header: { Text("Name") }) { (item: Package) in
                    Text(item.name)
                }
                TableColumn(width: .fitContent, alignment: .leading, header: { Text("Version") }) { (item: Package) in
                    Text(item.version)
                }
            }
        )

        let output = table.render()
        #expect(output.contains(ANSIColor.cyan.backgroundCode))
        #expect(output.contains("\u{001B}[1m"))
    }

    @Test("Row style helpers can add borders and underline text")
    func testRowStyleDecorations() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed")
        ]

        let table = Table(
            packages,
            divider: .none,
            rowStyle: { _, _ in
                TableRowStyle(
                    foregroundColor: .magenta,
                    isUnderlined: true,
                    border: .init(leading: "▶ ", trailing: " ◀")
                )
            },
            columns: {
                TableColumn("Name") { (item: Package) in
                    Text(item.name)
                }
            }
        )

        let rows = table.render().split(separator: "\n")
        let line = rows.dropFirst().first ?? ""
        #expect(line.contains("▶"))
        #expect(line.contains("◀"))
        #expect(line.contains(ANSIColor.magenta.rawValue))
        #expect(line.contains("\u{001B}[4m"))
    }

    @Test("Striped rows helper alternates styles")
    func testStripedRowsHelper() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed"),
            Package(id: 2, name: "Tuist", version: "4.0.0", status: "Outdated")
        ]

        let table = Table(
            packages,
            divider: .none,
            rowStyle: TableRowStyle.stripedRows(
                evenStyle: TableRowStyle(backgroundColor: .brightBlack),
                oddStyle: TableRowStyle(backgroundColor: .brightBlue)
            ),
            columns: {
                TableColumn("Name") { (item: Package) in
                    Text(item.name)
                }
            }
        )

        let lines = table.render().split(separator: "\n").dropFirst()
        let body = Array(lines.prefix(packages.count))
        #expect(body[0].contains(ANSIColor.brightBlack.backgroundCode))
        #expect(body[1].contains(ANSIColor.brightBlue.backgroundCode))
    }

    @Test("Divider style can be colored")
    func testColoredDivider() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed")
        ]

        let table = Table(
            packages,
            divider: .line(character: "─", color: .yellow, backgroundColor: .brightBlack, isBold: true),
            columns: {
                TableColumn("Name") { (item: Package) in
                    Text(item.name)
                }
            }
        )

        let output = table.render()
        #expect(output.contains(ANSIColor.yellow.rawValue))
        #expect(output.contains(ANSIColor.brightBlack.backgroundCode))
        #expect(output.contains("\u{001B}[1m"))
    }

    @Test("Key-path column sugar renders values with formatter")
    func testKeyPathColumnSugar() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed")
        ]

        let table = Table(
            packages,
            columns: {
                TableColumn("Name", value: \Package.name)
                TableColumn("Version", value: \Package.version) { version in
                    "v\(version)"
                }
            }
        )

        let lines = table.render().split(separator: "\n").map(String.init)
        #expect(lines.contains { $0.contains("Name") && $0.contains("Version") })
        #expect(lines.contains { $0.contains("Mint") && $0.contains("v0.17.2") })
    }

    @Test("Selection bindings highlight rows and focused row wins precedence")
    func testSelectionBindings() {
        let packages = [
            Package(id: 1, name: "Mint", version: "0.17.2", status: "Installed"),
            Package(id: 2, name: "Tuist", version: "4.0.0", status: "Outdated")
        ]

        let table = Table(
            packages,
            selection: .multiple(
                .constant([2]),
                focused: .constant(1),
                selectionStyle: TableRowStyle(backgroundColor: .magenta),
                focusedStyle: TableRowStyle(foregroundColor: .yellow, border: .init(leading: ">", trailing: "<"))
            ),
            columns: {
                TableColumn("Name", value: \Package.name)
            }
        )

        let lines = table.render().split(separator: "\n")
        // Header + rows, take body
        let body = Array(lines.dropFirst().prefix(packages.count))
        #expect(body[0].contains(">"))
        #expect(body[0].contains(ANSIColor.yellow.rawValue))
        #expect(body[1].contains(ANSIColor.magenta.backgroundCode))
    }
}
