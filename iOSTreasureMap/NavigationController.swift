import UIKit

class NavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {
    @IBOutlet weak var toggleSideMenu: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Menu stuff
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MenuViewController(),      menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 300.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
        navigationBar.backgroundColor = UIColor(red: 33, green: 194, blue: 184, alpha: 1)
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
}
//
//// MARK: - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {}
//// Get the new view controller using segue.destinationViewController.