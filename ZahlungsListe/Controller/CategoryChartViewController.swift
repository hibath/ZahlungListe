//
//  CategoryChartViewController.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 16.02.23.
//

import UIKit
import Charts
import RealmSwift
import PieCharts

class detailCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
}


class CustomProgressView: UIProgressView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}

class CategoryChartViewController: UIViewController {
    
    var categoryMG = CategoryManager()
    var budgetMG = BudgetManager()
    var categoryVC = CategoryViewController()
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    //var expenses = Expenses()
    //var sortedExpensesDic = [(String,Int)]()
    var categoriesArray : [Category]?
    let realm = try! Realm()
    var sliceSelected : PieSlice?
    @IBOutlet weak var  tableView: UITableView!
    @IBOutlet weak var progressBar: CustomProgressView!
    
    override func viewDidLoad() {
        // default value, need updating
        let budgetDefult = Budget()
        budgetDefult.value  = 3000
        do {
            try  self.realm.write {
                self.realm.add(budgetDefult)
            }
        } catch {
            print("error trying save data")
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        let expenses = categoryMG.getExpenses()
        categoriesArray = Array(categoryMG.loadCategories())
        totalLabel.text = String(expenses.total())+" $"
        budgetLabel.text = String(budgetMG.getBudget().value)+" $"
        let left = budgetMG.getBudget().value - expenses.total()
        leftLabel.text = String(left)+" $ left"
        let sortedExpensesDic = expenses.all().sorted(by: { $0.value > $1.value })
        drawPieChart(sortedExpensesDic: sortedExpensesDic)
    }
    
    func drawPieChart(sortedExpensesDic: [(String,Int)])
    {
        //draw the Pie chart
        pieChart.clear()
        pieChart.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChart.delegate = self
        pieChart.models = createModels(sortedExpensesDic: sortedExpensesDic) // order is important - models have to be set at the end 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden =  true
        navigationController?.isNavigationBarHidden = false
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "adding", style: .default) { [self] action1 in
            //what will happen when the user click the adding button on our alert
            let newCategory = Category()
            newCategory.name = textField.text!
            categoryMG.saveData(category: newCategory)
            // it should reload the array cuz the table reads from the array
            // we need to reload the category array
            self.categoriesArray = Array(self.categoryMG.loadCategories())
            self.tableView.reloadData()
            // update-redraw the Piechart
            let expenses = categoryMG.getExpenses()
            let sortedExpensesDic = expenses.all().sorted(by: { $0.value > $1.value })
            self.drawPieChart(sortedExpensesDic: sortedExpensesDic)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "add new Category here"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            action in
            // Called when user taps outside
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToGategory" , sender: self)
    }
    
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
        sliceSelected = slice
        performSegue(withIdentifier: "categoryDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "categoryDetails" {
            return
        }        
        let destinationVC = segue.destination as! PayingActTableViewController
        //  if let indexPath = tableView.indexPathForSelectedRow {
        for i in 0...categoriesArray!.count-1 {
            print(String(i))
            print(categoriesArray?[i].name as Any)
            // process here if we are coming from the pie chart or the table
            if let piePiece = sliceSelected {
                if categoriesArray?[i].name ==
                    piePiece.data.model.obj as? String {
                    destinationVC.selectedCategory = categoriesArray?[i]
                }
            }
            else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.selectedCategory = categoriesArray?[indexPath.row]
                }
            }
        }
        sliceSelected = nil
    }
}
        

    // MARK: -  PieChartDelegate

    extension CategoryChartViewController:  PieChartDelegate {
        
        
        fileprivate func createModels(sortedExpensesDic: [(String,Int)]) -> [PieSliceModel] {
            var colorIndex = 0
            var pieElements = [PieSliceModel]()
            let colorsArray = [UIColor(hexString: "98c1d9")!
                               ,UIColor(hexString: "e0fbfc")!
                               ,UIColor(hexString: "ee6c4d")!
                               ,UIColor(hexString: "edf2f4")!
                               ,UIColor(hexString: "e5e5e5")!
                               ,UIColor(hexString: "a69cac")!
                               ,UIColor(hexString: "3FE0D0")!
                               ,UIColor(hexString: "52BDFF")!
                              
                              
                               
                               
                               ,UIColor(hexString: "81D8D0")!
                               ,     UIColor(hexString: "4168E0")!]
            
            for (key,value) in sortedExpensesDic {
                print("\(key): \(value)")
                if value != 0 {
                    pieElements.append(PieSliceModel(value: Double(value), color: colorsArray[colorIndex], obj: key))
                    colorIndex += 1
                    if colorIndex == colorsArray.count-1{
                        colorIndex = 0
                    }
                }
                //print("\(key): \(value)")
            }
            return(pieElements)
        }
        
        // MARK: - Layers
        
        fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
            let viewLayer = PieCustomViewsLayer()
            let settings = PieCustomViewsLayerSettings()
            settings.viewRadius = 135
            settings.hideOnOverflow = false
            viewLayer.settings = settings
            viewLayer.viewGenerator = createViewGenerator()
            return viewLayer
        }
        
        fileprivate func createTextLayer() -> PiePlainTextLayer {
            let textLayerSettings = PiePlainTextLayerSettings()
            textLayerSettings.viewRadius = 120
            textLayerSettings.hideOnOverflow = false
            textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            textLayerSettings.label.textGenerator = {slice in
                return ((formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)% "} ?? "") + String((slice.data.model.obj as! String? ?? "")))  // need reparing here
            }
            
            let textLayer = PiePlainTextLayer()
            textLayer.settings = textLayerSettings
            return textLayer
        }
        
        fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
            return {slice, center in
                
                let container = UIView()
                container.frame.size = CGSize(width: 100, height: 40)
                container.center = center
                let view = UIImageView()
                view.frame = CGRect(x: 30, y: 0, width: 40, height: 40)
                container.addSubview(view)
                
                if slice.data.id == 3 || slice.data.id == 0 {
                    let specialTextLabel = UILabel()
                    specialTextLabel.textAlignment = .center
                    if slice.data.id == 0 {
                        //  specialTextLabel.text = "views"
                        specialTextLabel.font = UIFont.boldSystemFont(ofSize: 18)
                    } else if slice.data.id == 3 {
                        specialTextLabel.textColor = UIColor.blue
                        // specialTextLabel.text = "Custom"
                    }
                    specialTextLabel.sizeToFit()
                    specialTextLabel.frame = CGRect(x: 0, y: 40, width: 100, height: 20)
                    container.addSubview(specialTextLabel)
                    container.frame.size = CGSize(width: 100, height: 60)
                }
                            
                // src of images: www.freepik.com, http://www.flaticon.com/authors/madebyoliver
                let imageName: String? = {
                    switch slice.data.id {
                    case 0: return "fish"
                    case 1: return "grapes"
                    case 2: return "doughnut"
                    case 3: return "water"
                    case 4: return "chicken"
                    case 5: return "beet"
                    case 6: return "cheese"
                    default: return nil
                    }
                }()
                
                view.image = imageName.flatMap{UIImage(named: $0)}
                return container
            }
        }
        
        
    }


// MARK: - table Delegate, Datasource

extension CategoryChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celled", for: indexPath) as! detailCell
        cell.backgroundColor = UIColor.white
        if let category = categoriesArray?[indexPath.row]{
            let expenses = categoryMG.getPaying(category: category)
            cell.name.text = category.name
            cell.value.text = String(expenses)+" $"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
