import SwiftUI
import UIKit

struct PageCurlView: UIViewControllerRepresentable {

    let pages: [AnyView]

    func makeCoordinator() -> Coordinator {
        Coordinator(pages: pages)
    }

    func makeUIViewController(
        context: Context
    ) -> UIPageViewController {

        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [
                .spineLocation:
                    UIPageViewController.SpineLocation.min.rawValue
            ]
        )

        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.isDoubleSided = false
        controller.view.backgroundColor = .clear

        if let firstPage = context.coordinator.controllers.first {
            controller.setViewControllers(
                [firstPage],
                direction: .forward,
                animated: false
            )
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIPageViewController,
        context: Context
    ) {
    }

    final class Coordinator: NSObject,
                             UIPageViewControllerDataSource,
                             UIPageViewControllerDelegate {

        let controllers: [UIViewController]

        init(pages: [AnyView]) {
            controllers = pages.map { page in
                let controller = UIHostingController(rootView: page)
                controller.view.backgroundColor = .clear
                return controller
            }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {

            guard
                let index = controllers.firstIndex(
                    where: { $0 === viewController }
                ),
                index > 0
            else {
                return nil
            }

            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {

            guard
                let index = controllers.firstIndex(
                    where: { $0 === viewController }
                ),
                index < controllers.count - 1
            else {
                return nil
            }

            return controllers[index + 1]
        }
    }
}
