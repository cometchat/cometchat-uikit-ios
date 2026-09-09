

public class ChatConfigurator {
    
    static var dataSource: DataSource = MessagesDataSource()
    static var names = [MessagesDataSource().getId()]
    
    @discardableResult
    init(initialSource: DataSource?) {
        ChatConfigurator.dataSource = initialSource ?? MessagesDataSource()
        ChatConfigurator.names = [ChatConfigurator.dataSource.getId()]
    }
    
    static func enable(_ fun: (_ dataSource: DataSource) -> DataSource) {
        let oldSource = self.dataSource
        let newSource = fun(oldSource)

        // A decorator reporting its wrapped source's id must not stack again.
        if newSource.getId() == oldSource.getId() || names.contains(obj: newSource.getId()) {
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
