//
//  OrgReposTableViewFactory.swift
//  CleanRepoViewer
//
//  Created by Miksa on 23.12.25.
//

import UIKit

enum OrgReposTableViewFactory {
    static func makeTableView() -> UITableView {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .background
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = Spacing.Layout.estimatedRowHeight
        table.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Spacing.Space.xl,
            right: 0
        )
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        return table
    }
}
