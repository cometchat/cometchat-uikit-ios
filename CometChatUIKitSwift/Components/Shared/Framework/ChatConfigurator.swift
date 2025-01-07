

public class ChatConfigurator {
    
    static var dataSource: DataSource = MessagesDataSource()
    static var names = ["message utils"]
    
    @discardableResult
    init(initialSource: DataSource?) {
        ChatConfigurator.dataSource = initialSource ?? MessagesDataSource()
        ChatConfigurator.names = ["message utils"]
    }
    
    static func enable(_ fun: (_ dataSource: DataSource) -> DataSource) {
        let oldSource = self.dataSource
        let newSource = fun(oldSource)

        if names.contains(obj: newSource.getId()) {
            debugPrint("Already added")
        } else {
            self.dataSource = newSource
            debugPrint("Added interface is \(String(describing: dataSource.getId()))")
            names.append(dataSource.getId())
        }
    }
    
   static func getDataSource() -> DataSource {
        return dataSource
    }
}
