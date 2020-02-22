#  JS Operations:
This is a simple project that highlights the use of `WKWebView` to load and evaluate arbitrary javascript code and communicate it back to the native side.

## Architecture:
This project utilizes a single `UIViewController` wrapped within a `UINavigationController` to display the activity being performed in the javascript context within a `WKWebView`. The `WKWebView` instance is only being used for its javascript runtime and is not visible. A deeper dive into the architecture is as follows:

* ### JSLoader:
`JSLoader` is a factory class that helps with downloading raw data at a valid network `URL`. The static nature of it makes it easy to be tested as well as expanded as needed. Due to the asynchronous nature of the network call, the factory method relies on a delegate following `JSLoaderDelegate` protocol to invoke a completion with the result.

* ### JumboMessage:
`JumboMessage` is the domain model for the communication channel between `WKWebView`'s javascript runtime and the native side. It also implements the `Codable` protocol for easy `JSON` encoding and decoding.

* ### JumboService:
Due to the simplicity of the scope of this project, much of the business logic is included in the `JumboService`. Once the `JSLoader` has loaded the javascript bundle, this service takes charge and determines when the setup has been done and when to start making the call on the javascript runtime. It uses `JumboMessage` `struct` to serialize and deserialize data and works as the messenger between the `JumboViewController` and the javascript runtime. This service uses a lot of `weak` references to other instances due to its inherent nature of being the messenger. This avoids adding additional ticks to the `ARC` when all the references are used for is as delegates.

* ### ABProgressView:
This is a custom view that extends `UIView`. The representation of a `JumboMessage` is completely covered by the `ABProgressView`. It updates itself based on the state of `JumboMessage` it is bound to. The modularity of the `ABProgressView` allows it to be added to a `UIStackView` for reusability.

* ### JumboViewController:
This is where the visual portion of the app lives. `JumboViewController` is embedded within a `UINavigationController`. Other than setting the title and starting the services, this controller does nothing more than managing immediate user interface changes - including passing the data flow downstream to the multiple instances of `ABProgressViews`. The layout is designed in the storyboard and minimal handling of view is down by applying appropriate constraints such the `ABProgressViews` is embedded within a `UIStakcView`, which itself is housed in a `UIScrollView` so as to allow all the items to be visible despite the height of various devices and different orientations. This is where if any additional scope was determined for the progress displays, it could be housed within a `UITableView`. However, for what was to be accomplished, the described layout will suffice.

## Testing and beyond:
Unit tests are included for `JSLoader` and `JumboService` along with mock and fake objects as needed to test them. `JSOperationTests` houses the implemented and passing unit tests that cover very basic level of testing. By no means are they exhaustive but enough screening was provided for me to find out some simple bugs.

UI tests are not included, though I left the default generated test file in `JSOperationsUITests`.
