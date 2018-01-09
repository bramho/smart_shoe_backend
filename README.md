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
   
   
   func sensorDataReceivedFromShoe(_ data: Shoe) {
      print(data.getShoe(maxValue: 500)) // This normalizes data to a value compared to 500. Raw Values are also usable by getting .getSensors before.
   }
}
```

Afterwards you are able to call `manager.startConnectionSession()` and `manager.stopConnectionSession()`. Start initializes the connection session to the Shoe. If, in the meantime, you want to give the user the opportunity to cancel this proces, call the stop connection session.

A connection session restarts automatically if needed and will automatically output the data from the shoe when connected.

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
   
   
   func sensorDataReceivedFromShoe(_ data: Shoe) {
      print(data.getShoe(maxValue: 500)) // This normalizes data to a value compared to 500. Raw Values are also usable by getting .getSensors before.
   }
   
   func stateUpdated(_ state: Int, _ error: String?) {
      //Implement the handling of the states here. If you want to view the 'values' of the states, you can view them in the StateManager file. 
   }
}
```

### SessionStorage
If you're wanting to use the inbuilt SessionStorage and Player, they're both singletons. While SessionStorage is mainly used internally to store the data and validate it so it works, the Player will be mainly what'll be used. You can see a basic implementation below.

```
class ViewController: UIViewController, ShoeManagerDelegate, SessionPlayerDelegate {
    var shoeManager : ShoeManager! //this is implicitly typed as it's set later.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shoeManager = ShoeManager.init() // Initialize new Shoe Manager
        shoeManager.delegate = self
        SessionPlayer.instance.delegate = self
    }

    func sensorDataReceivedFromShoe(_ data: Shoe) {
        print(data.getShoe(maxValue: 500)) // This normalizes data to a value compared to 500. Raw Values are also usable by getting .getSensors before.
    }
    
    func sessionPlayDataUpdated(_ data: Shoe) {
        // This function works similarly to 'sensorDataReceivedFromShoe'. Keep this in mind when implementing the SessionStorage for use in your own application.
        print(data.getShoe(maxValue: 600).getSensors())
    }
    
    @IBAction func demoSession(_ sender: Any) {
        SessionPlayer.instance.demoSession()
    }
}
```

