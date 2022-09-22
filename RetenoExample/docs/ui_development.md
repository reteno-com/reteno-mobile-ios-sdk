# UI development

## Overview

All UI is developed via code in the project.

While people have mixed opinions about **code-based UI development**, we believe that view coding is the best option as it allows multiple people to code in the same screen at the same time, merge conflicts are simple and you gain more control over your screens. You don't need to wait a long time for Xcode to load the visual representation of your screen - everything is just regular code.

In addition, this allows use to use dependency injection in a straight forward manner. You'll see that there are no singletons in a project - everything relevant to a class must be directly sent to it. This allows us to write better tests and make sure that classes can only do what they are supposed to.

## Usage

To develop new screen UI need to:

	- Create new ViewController (`UIViewController`)
	- Create and layout new View (`UIView`) of screen, where all UI is represented
	- Assign created View (`UIView`) to the ViewController's (`UIViewController`'s) view property in the `loadView` method

#### View

The View is where everything regarding the visual aspect of the ViewController should be built and retained. All Views for screens should be located in the `UI` framework.
To layout everything in View, use `NSLayoutAnchor`'s wrapper functions, implemented in `Autolayout.swift`.

As we use code-base UI development, we need to exclude `required init?(coder aDecoder: NSCoder)` initializer. To do it for ALL Views in the `UI` framewrok was created `BaseView` class, where this restriction was done. So all custom Views in the `UI` framework should be subclasses of `NibllessView`.

Example:

```
final public class SomeView: BaseView {
    
    //...

    public override init() {
        super.init()
        
        setupViews()
    }
    
    private func setupViews() {
        let title = UILabel()
        title.text = L10n.Temp.text
        addSubview(title)

        // Layout usage example

        title.layout {
            $0.top.equal(to: layoutMarginsGuide.topAnchor, offsetBy: 23)
            $0.centerX.equal(to: centerXAnchor)
            $0.width.equal(to: 280)
            $0.height.equal(to: 68)
        }
    }

    //...
```

**View coding guide**:

Do not configure subviews in its declaration, example
    ```
    public let messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "chatMessageLabel"
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = ChatAppearanceConfig.Message.font
        label.textColor = ChatAppearanceConfig.Message.color
        
        return label
    }()
    ```

    DO NOT DO LIKE IN PREVIOS EXAMPLE! 

    All subviews should be just declared and visible as a list for clear reviewing what this view is consist of. Configuration of view should be done in the appropriate method. Fox example:

    ```
    public class NameView: BaseView {

        // ....
        
        private let titleLabel: UILabel = UILabel()

        // ....
        
        // MARK: - Init
        
        public override init() {
            super.init()
            
            //...

            setupViews()
        }
        
        // MARK: - Layout
        
        private func setupViews() {
            setupTitleLabel()
            // ....
        }
        
        private func setupTitleLabel() {
            titleLabel.accessibilityIdentifier = "titleLabel"
            titleLabel.font = FontFamily.SFProDisplay.bold.font(size: 28.0)
            titleLabel.text = L10n.Screen.PhoneAuth.title
            
            addSubview(titleLabel)
            titleLabel.layout {
                $0.top.equal(to: layoutMarginsGuide.centerYAnchor, offsetBy: LayoutValue.Autorization.titleCenterYOffset)
                $0.centerX.equal(to: centerXAnchor)
            }
        }

    }
    ```

    Such approach is more readable and convinient.
    
#### ViewController

ViewController is a screen itself. It contains developed and layouted View in it to represent UI. ViewController can setup View and communicate with it to change UI state.
View should be set in the overriden `loadView` method.

As we use code-base UI development, we need to exclude `required init?(coder aDecoder: NSCoder)` initializer. To do it for ALL ViewControllers in the was created `NiblessViewController` class, where this restriction was done. So all ViewControllers should be subclassed from it.
