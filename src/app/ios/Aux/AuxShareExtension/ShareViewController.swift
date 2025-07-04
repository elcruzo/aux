//
//  ShareViewController.swift
//  AuxShareExtension
//
//  Created by Ayomide Adekoya on 7/3/25.
//

import UIKit
import SwiftUI

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract URL from share context
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (item, error) in
                DispatchQueue.main.async {
                    if let url = item as? URL {
                        self?.handleURL(url)
                    } else {
                        self?.close()
                    }
                }
            }
        } else {
            close()
        }
    }
    
    private func handleURL(_ url: URL) {
        // Create SwiftUI view
        let shareView = ShareView(
            url: url.absoluteString,
            extensionContext: extensionContext,
            onDismiss: { [weak self] in
                self?.close()
            }
        )
        
        let hostingController = UIHostingController(rootView: shareView)
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

struct ShareView: View {
    let url: String
    let extensionContext: NSExtensionContext?
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with logo
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Spacer()
                
                Button("Cancel") {
                    onDismiss()
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            VStack(spacing: 16) {
                Text("Convert Playlist")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Open this playlist in Aux to convert it")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // URL preview
                Text(url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action button
            Button(action: {
                openInAux()
            }) {
                Text("Open in Aux")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color("BackgroundColor"))
    }
    
    private func openInAux() {
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let auxURL = URL(string: "aux://convert?url=\(encodedUrl)") else {
            onDismiss()
            return
        }
        
        // Open the URL in the main app
        // Note: Share extensions cannot directly open URLs, so we use the extension context
        extensionContext?.open(auxURL, completionHandler: nil)
        
        onDismiss()
    }
}