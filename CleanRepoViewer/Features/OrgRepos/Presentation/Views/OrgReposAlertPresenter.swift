//
//  OrgReposAlertPresenter.swift
//  CleanRepoViewer
//
//  Created by Miksa on 23.12.25.
//

import UIKit

final class OrgReposAlertPresenter {

    private weak var presenter: UIViewController?

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    func showError(message: String, onRetry: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Retry", style: .default) { _ in
                onRetry()
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        guard let presenter else { return }

        if presenter.presentedViewController == nil {
            presenter.present(alert, animated: true)
        }
    }
}
