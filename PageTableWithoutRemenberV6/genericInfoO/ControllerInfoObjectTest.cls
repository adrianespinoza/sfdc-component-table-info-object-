@isTest
public class ControllerInfoObjectTest {
    static string buildObject()
    {
        Account a = new Account();
        a.Name = 'testAccount';
        Database.SaveResult result = Database.Insert(a);
        if (result.isSuccess()) {
            return result.getId();
        }
        return '';
    }
    static testMethod void processInfoTest()
    {
        ControllerInfoObject controller = new ControllerInfoObject();
        String id = buildObject();
        controller.searchById = id;
        
        System.assertEquals('Account', controller.objectLabel);   
    }
    static testMethod void processInfoTest2()
    {
        ControllerInfoObject controller = new ControllerInfoObject();
        controller.searchById = null;
        
        //System.assertEquals('Merchandise', controller.objectLabel);   
    }
    static testMethod void saveObjectTest()
    {
        ControllerInfoObject controller = new ControllerInfoObject();
        String id = buildObject();
        if(id != '') {
            controller.resultObject = [SELECT Name FROM Account WHERE id = : id];
            Account a = (Account)controller.resultObject;
            a.Name = 'tested';
        
            controller.resultObject = a;
        
            Test.startTest();
            controller.saveObject();
            Test.stopTest();
        
            Account res = [SELECT Name FROM Account WHERE id = : id];
               
            System.assertEquals('tested', res.Name);
         }
    }  
}