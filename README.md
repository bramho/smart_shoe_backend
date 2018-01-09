# Smart Shoe Backend

This Backend facilitates the connection and data-transfer between a Swift application and a pair of IOFit Smart Shoes. 

# Installing

Just download the files and place them in a seperate file folder in your xcode project.

# Usage

In order to use the backend, there are a couple of things you need to have in the class where you implement it. Since it's attached to your project, you will not need to import the backend as it's available in global scope.

To use the backend, implement the ShoeManagerDelegate as set in the ViewController file in the Backend and implement the protocol stub. Subsequently, you will need to create a reference to the ShoeManager and set it's delegate to the file you're trying to run it from, for example:

```
class ViewController: UIViewController, ShoeManagerDelegate {
   var manager: ShoeManager! //this is implicitly typed as it's set later. 
   
   override func viewDidLoad(){
    viewDidLoad.super()
    
    manager = ShoeManager.init() // Initialize new Shoe Manager
    manager.delegate = self
   }
   
   
   sensorDataReceivedFromShoe(_ data: Shoe) {
      print(data.getShoe(maxValue: 500)) // This normalizes data to a value compared to 500. Raw Values are also usable by getting .getSensors before.
   }
}
```
# Additional Systems

### StateManager
If you're wanting ot use the inbuilt StateManager, it's a singleton. Simply call 'StateManager.instance' in order to access it's (public) properies using the functions. In order to implement 'tracking' of the State Changes, you will need to implement the StateManagerDelegate as follows:

```
class ViewController: UIViewController, ShoeManagerDelegate, StateManagerDelegate {
   var manager: ShoeManager! //this is implicitly typed as it's set later. 
   
   override func viewDidLoad(){
    viewDidLoad.super()
    
    manager = ShoeManager.init() // Initialize new Shoe Manager
    manager.delegate = self
    
    StateManager.instance.delegate = self
   }
   
   
   sensorDataReceivedFromShoe(_ data: Shoe) {
      print(data.getShoe(maxValue: 500)) // This normalizes data to a value compared to 500. Raw Values are also usable by getting .getSensors before.
   }
   
   func stateUpdated(_ state: Int, _ error: String?) {
      //Implement the handling of the states here. If you want to view the 'values' of the states, you can view them in the StateManager file. 
   }
}
```
