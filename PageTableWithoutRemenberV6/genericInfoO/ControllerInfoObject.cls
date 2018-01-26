Global with sharing class ControllerInfoObject {
    public List<String> fields {get;set;}
    public map<String,String> mapFieldLabel {get;set;}
    public SObject resultObject {get;set;}
    public String objectType {get;set;}//the API name information
    public String objectLabel {get;set;}//the label information    
    private String getQuery {get;set;}
    private String searchId;
    public String searchById {
        get;
        set {            
            if(searchId == null) {                
                if(value == null || value == '') {
                    String id = ApexPages.currentPage().getParameters().get('id');
                    if(id == null || id == '') {                        
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'There was no id.'));
                    } else {
                        searchId = id;
                        processInfo(id);
                    }
                } else {
                    searchId = value;
                    processInfo(value);
                }
            }
            System.debug('idObjectGlobal property');          
        }
    }
    
    public ControllerInfoObject(){
        getQuery = '';
        fields = new List<String>();
        mapFieldLabel = new map<String, String>();
        System.debug('Constructor');
    }
        
    private void processInfo(String id){
        List<Schema.SObjectField> tempFields;
        Schema.DescribeSObjectResult objDescribe;
        //only for a object
        if(id != null) {
            objectType = ((ID)id).getSObjectType().getDescribe().getName();
            objectLabel = ((ID)id).getSObjectType().getDescribe().getLabel();
            objDescribe = ((ID)id).getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            tempFields = fieldMap.values();
            for(Schema.SObjectField sof : tempFields) {
                fields.add(sof.getDescribe().getName());
                mapFieldLabel.put(sof.getDescribe().getName(), sof.getDescribe().getLabel());
            }
            getQuery = buildQuery(fields,objDescribe,id);
            try {
                resultObject = Database.query(getQuery);
            } catch (Exception e) {
                resultObject = null;
            }
            
        }
    }
    
    private String buildQuery(List<String> queryFields,DescribeSObjectResult obj, String theId) {
        String query = 'select ' + String.join(queryFields, ',');
        query += ' from ' + obj.getName();
        query += ' where Id = \'' + theId + '\'';
        
        return query;
    }
    
    public void saveObject() {
        update(resultObject);
    }
    
    public PageReference calcelObject() {
        PageReference pageRef = ApexPages.currentPage();
        return pageRef;
    }
}