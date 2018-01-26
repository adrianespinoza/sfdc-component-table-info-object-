public with sharing class ControllerTemp {
    public List<String> listFields { get; set; }
    public String objectName { get; set; }
    public List<ActionButton> listActions { get; set; }
    
    public ControllerTemp() {
        objectName = 'Merchandise__c';
        listFields = new List<String>();
        listFields.add('Name');
        listFields.add('aveh1__Price__c');
        listFields.add('aveh1__Total_Inventory__c');
        listFields.add('aveh1__Description__c');
        
        listActions = new List<ActionButton>();
        listActions.add(new Action1());
        listActions.add(new Action2());
    }
    public class Action1 implements ActionButton {
        public Boolean executeAction(String objApiName, Set<String> setIds) {
            if(setIds.isEmpty()) {
                return false;
            }
            try {
                for(String id : setIds) {
                    DataBase.delete(id);
                }
                return true;
            } catch(DmlException e) {
                return false;
            }
        }
        public String getActionType() {
            return 'Delete2';
        }
    }
    public class Action2 implements ActionButton {
        public Boolean executeAction(String objApiName, Set<String> setIds) {
            //some action
            return true;
        }
        public String getActionType() {
            return 'Action2';
        }
    }
}