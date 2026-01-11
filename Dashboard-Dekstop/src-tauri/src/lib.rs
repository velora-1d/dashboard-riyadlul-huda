// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

use tauri_plugin_opener::OpenerExt;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            // Programmatically create the window
            let app_handle = app.handle().clone();
            let _window = tauri::WebviewWindowBuilder::new(
                app,
                "main",
                tauri::WebviewUrl::External("https://dashboard.riyadlulhuda.my.id".parse().unwrap()),
            )
            .title("Santrix Dashboard")
            .inner_size(1280.0, 800.0)
            .initialization_script(r#"
                // Force all target="_blank" to open in the same window so we can catch them in Rust
                document.addEventListener('click', (e) => {
                    const link = e.target.closest('a');
                    if (link && link.target === '_blank') {
                        link.target = '_self';
                    }
                }, true);
            "#)
            .on_navigation(move |url: &tauri::Url| {
                let url_str = url.as_str();
                let is_download = url_str.contains("export") || 
                                 url_str.contains("download") || 
                                 url_str.contains("template") ||
                                 url_str.ends_with(".pdf") ||
                                 url_str.ends_with(".xlsx") ||
                                 url_str.ends_with(".csv");

                if is_download {
                    println!("🚀 Intercepted download URL in Rust: {}", url_str);
                    let _ = app_handle.opener().open_url(url_str, None::<&str>);
                    return false; // Stop navigation in the webview
                }
                true // Allow regular navigation
            })
            .build()?;

            Ok(())
        })
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
