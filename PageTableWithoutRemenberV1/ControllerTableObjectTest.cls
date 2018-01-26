public class ControllerTableObjectTest {
    static void buildDataBase() {
        for(Integer i = 0; i < 6; i++) {
            Account a = new Account();
            a.Name = 'Jhospel' + i;
            insert(a);
        }
    }
    
    static testMethod void doQueryWithListFieldTest() {
        buildDataBase();
        ControllerTableObject controller = new ControllerTableObject();
        controller.sObjectName = 'Account';//init variable
        
        List<String> sObjectFields= new List<String>();
            
            sObjectFields.add('Id');
            sObjectFields.add('Name');
            
        controller.sObjectFields = sObjectFields;//init variable
        controller.recordNumber = 2;//init variable
        controller.startPage = 1;//init all variables 
        
        Integer startPage = controller.startPage;
        
        controller.sortField = 'Name';
        controller.sortField = 'Name';//for cover all       
        
        System.assertEquals('Account', controller.objectNameLabel);
    }
    
    static testMethod void doQueryWithFieldSetNameTest() {
        buildDataBase();
        ControllerTableObject controller = new ControllerTableObject();
        controller.sObjectName = 'Account';//init variable
        
        List<String> sObjectFields= new List<String>();
            
            sObjectFields.add('Id');
            sObjectFields.add('Name');
            
        controller.sObjectFields = sObjectFields;//init variable
        controller.fieldSetName = 'aveh__FS_ViewAccount';
        controller.recordNumber = 2;//init variable
        controller.startPage = 1;//init all variables
        
        System.assertEquals('Account', controller.objectNameLabel);
    }
    
    static testMethod void nextPreviousTest() {
        buildDataBase();
        ControllerTableObject controller = new ControllerTableObject();
        controller.sObjectName = 'Account';//init variable
        
        List<String> sObjectFields= new List<String>();
            
            sObjectFields.add('Id');
            sObjectFields.add('Name');
            
        controller.sObjectFields = sObjectFields;//init variable
        controller.recordNumber = 2;//init variable
        controller.startPage = 1;//init all variables
        
        if(controller.hasNext) {
            controller.next();        
            System.assertEquals(2, controller.getPageNumber());
        }
        
        if(controller.hasPrevious) {
            controller.previous();        
            System.assertEquals(1, controller.getPageNumber());
        }
        
        if(!controller.hasPrevious) {
            controller.last();        
            System.assertEquals(3, controller.getPageNumber(), 'getPageNumber()');
        }      
        
        if(!controller.hasNext) {
            controller.first();
            System.assertEquals(1, controller.getPageNumber());
        }
        
        controller.restQuery = 'Jhospel1';
        controller.searchByCritery();
        
        System.assertEquals(1, controller.resultObject.size());
    }
}