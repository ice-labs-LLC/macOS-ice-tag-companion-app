import SwiftUI

@main
struct ice_tag_app: App {
    @Environment(\.openWindow) private var openWindow
    @AppStorage("usesystemsettings") private var usesystemsettings = true
    @AppStorage("appearancemode") private var appearancemode = "light"

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(action: { openWindow(id: "info") }) {
                    Label("About ice tag", systemImage: "info.circle")
                }
            }
            CommandGroup(after: .appTermination) {
                Button(action: { exit(0) }) {
                    Label("Force Quit", systemImage: "power")
                }
                .keyboardShortcut("q", modifiers: [.command, .option])
            }
        }

        Settings {
            VStack(alignment: .leading, spacing: 25) {
                // Appearance Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("APPEARANCE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $appearancemode) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .disabled(usesystemsettings)
                }
                
                Divider()
                
                // Native System Slider Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("SYSTEM")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    // This is the Native SDK "Liquid Glass" Slider
                    Toggle("Match System Settings", isOn: $usesystemsettings)
                        .toggleStyle(.switch)
                        .font(.system(size: 13, weight: .semibold))
                        .tint(.green) // Sets the "Liquid" color when ON
                }
            }
            .padding(30)
            .frame(width: 350, height: 220)
        }

        // Loads content from InfoView.swift
        Window("About ice tag", id: "info") {
            InfoView()
        }
        .windowResizability(.contentSize)
    }
}
