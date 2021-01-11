//
//  DemoListView.swift
//  VComponentsDemo
//
//  Created by Vakhtang Kontridze on 1/11/21.
//

import SwiftUI
import VComponents

// MARK:- Demo List View
struct DemoListView<Row>: View where Row: DemoableRow {
    // MARK: Properties
    private let sections: [DemoSection<Row>]
    
    private let lazyListModel: VLazyListModelVertical = {
        var model: VLazyListModelVertical = .init()
        model.layout.spacing = 20
        return model
    }()
    
    // MARK: Initializers
    init(sections: [DemoSection<Row>]) {
        self.sections = sections
    }
}

// MARK:- Body
extension DemoListView {
    var body: some View {
        ZStack(content: {
            ColorBook.canvas.edgesIgnoringSafeArea(.bottom)
            
            VLazyList(model: .vertical(lazyListModel), data: sections, rowContent: { section in
                VSection(title: section.title, data: section.rows, content: { row in
                    DemoListRowView(title: row.title, destination: row.body)
                })
                    .padding(.trailing, 16)
            })
                .padding([.leading, .top, .bottom], 16)
        })
    }
}

// MARK: Preview
struct DemoListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView_Previews.previews
    }
}
