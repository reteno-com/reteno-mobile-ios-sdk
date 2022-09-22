# Architecture

## App Architecture

App’s architecture based on **Modular** approach. The main idea is to construct application from smaller flows with ability freely reuse, include/exclude and change flows order in application. **Module** is a logical user flow in app called `FlowCoordinator`.

`FlowCoordinator` contains a list of screens (at least one screen). *FlowCoordinator* is responsible for its screens management, routing of screens and can handle flow’s common logic. So, `FlowCoordinator` creates/removes, configures screens and handles its order. Also, it can create/remove and present other *FlowCoordinator*s. It means that architecture represents as tree-based structure, which simplifies understanding and orientation throughout the application.

Each `FlowCoordinator` in app implements FlowCoordinator interface:

- Flow implements `func createFlow() -> UIViewController` method. It creates initial screen from  which flow should be started. Initial screen object is returned to flow’s creator (parent flow), so flow creator can show this screen in UI (push, present, show in container, etc...).

- Also flow has optional `var containerViewController: UIViewController? { get set }`. This is container screen in which flow can be presented. It should be set outside of the flow by flow creator, because container is an external environment for flow. For e.g. a container can be `UINavigationController`, so when developer needs to show flow in navigation controller, initial screen of flow should be put to the `UINavigationController` and set this `UINavigationController` to `coinatinerViewController` property of presented flow (to give an ability show next flows / screens in flows in the same navigation).

To initialize `FlowCoordinator`, it's needed to provide parent Flow (`parentNode`) and dependencies (`parentContainer`).

#### Swinject

For DI is used `Swinject` https://github.com/Swinject/Swinject - all dependencies (services) are transmitted throug Flows by tree and parent injects to its children dependencies via DI container. DI container is used to distribute ONLY services as dependencies. Screens (`ViewController`s) and children Flows (`FlowCoordinators`) dependencies shouldn't be added via `Swinject` (to the DI container) by security (incapsulation) reasons - children flows shouldn't know about inner logic of parent flows (incapsulated screens).

## Screens Architecture

Screens may be implemented using **MVC** or **MVVM** patterns. Pattern usage depends on screen complexity and reusability of it in the project:

#### MVC

We try to use **MVC** pattern where it's possible to reduce code complexity and possible overheads. *Description*:

- Active **Model** is responsible for storing rough data for screen, screen's business logic (validate some data, react on user's actions with data, etc.), usage of `Core`'s services, subscribing on / sending events by the tree.
- **View** is located in the `UI` framework and it responsible for creating, layouting and animating views
- **ViewController** is just a **Controller** which communicates with Model and View and connects each other. It's responcible for binding and mapping rough data stream from Active **Model** to the **View** and vice versa.

So, the majority of screens could be built using **MVC** pattern, because it's quite simple, readable and also powerful because we have moved out **View**'s presentation logic to the separate independent class - it helps a lot to divide responsibilities and write in not strongly connected way.

#### MVVM

Also, it's possible to use **MVVM** pattern for screens. Its difference from **MVC** - adding of new pattern member - **ViewModel**.

- **ViewModel** is responsible for representation. It takes mapping data responsibility from **ViewController** on itself. In general **ViewModel** is responsible for: mapping and preparing rough data from Active **Model** for the **View** (in our case for the **ViewController**), representation logic (logic of screen states - show/hide spinner for e.g., change layout by request, etc.).
- **ViewController** in **MVVM** is a part without which screen can't exist, because we need `UIViewController` subclass. It binds already prepared data from **ViewModel** to the **View**(s).

So, because of `UI` framework existance (moved out **View** from **ViewController**) we can see that there is no big difference between between **MVC** and **MVVM**, moreover **MVVM** looks like an overhead. 

But! There are still cases when it's more appropriate to use **MVVM**:

- When screen is too complicated and realy large, when **ViewController** is quite big class - it's justified to move out logic of representation from **ViewController** to the **ViewModel**, just to make it more readable and add strict responsibilities for elements of pattern (which is better to understand).
- When screen's UI/Layout could be reused in application, but it's representation and/or business logic may differentiate/vary. For e.g.: we have screen with button with title "A" and with action `A` by tapping this button. Also, in app, we have screen with IDENTICAL UI and Layout, EXCEPT - button has title "B" and action `B` by tapping it. In such case it's better to create **ViewModel** and (if needed) **Model** interface (protocol) and change representation or logic by creating of new implementations of interfaces. So **ViewController** would work with **ViewModel** interface and it's represention would differentiate/vary depends on **ViewModel** implementation.
Such approach minimizes code to write to reuse screen and makes it flexible to change it.

#### RxSwift

For bindnings and fast communications (callbacks) between elements of pattern used reactive programming approach, specifically reactive tool - `RxSwift` library https://github.com/ReactiveX/RxSwift.

## Communications between flows and screens

Since app architecture is a tree-based structure we have used it to set up communications between flows and screens. 
Flows and screens are tree nodes. Each `FlowCoordinator` has parent flow and children - it can be another `FlowCoordinator` or active model of screen which maintained by flow. So, to send messages to children flows / screens or send output events for parents we can use tree - raise or propagate events to tree nodes by chain.

To make `FlowCoordinator` or screen’s active `Model` as a tree node, you need to subclass it from `NavigationNode` class, which has  raise and propagate methods for sending events. To handle events in node need to register self as a handler of particular event via `func addHandler<T: NavigationEvent>(_ handler: @escaping (T) -> Void)` method.

## XCTemplates

Creation of Flows and Screens is time consuming activities, because of number of files to create or base code to write. So, to make creation of it faster, we moved common code and base files to the `xctemplate` files located in the `.../XCTemplates`. Add it to your Xcode templates and use in creation of Flows or Screens

