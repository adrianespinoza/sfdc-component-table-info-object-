global with sharing class ControllerTableObject {
    public String sObjectName{get; set;}//API name of a object it is received from out
    public List<String> sObjectFields{get; set;}//API names of the fileds it is received from out
    public String fieldSetName{get; set;}//a name of fieldSet
        
    private Integer rNumber;
    public Integer recordNumber { //it is received from out is the number of registers that it will show us in each page 
        get { return rNumber; } 
        set {
            if(value != null) {
                rNumber = value;
            } else {
                rNumber = 5;//by default is five
            }
        }
    }
    public Integer startPage{
        get{ return sp; }
        set{                       
            if(value != null && recordsTotal == null && sObjectName != null){
                pageNumber = value;//out
                sp = value;
                String QueryString = 'SELECT count() FROM ' + sObjectName; 
                recordsTotal = Database.countQuery(QueryString);
                totalPages = setupTotalPages();             
                
                mapFieldToShow = getFieldsMap(sObjectName);
                
                //verifying if the user had introduced a name of a fielset
                if(fieldSetName != null && fieldSetName != '' && sObjType != null) {                    
                    try {
                    List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
                    fields = sObjType.getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
                    if(fields.size() > 0) {
                        sObjectFields.clear();//by priority
                        for(Schema.FieldSetMember fsm : fields) {
                            String field = fsm.getFieldPath();
                            sObjectFields.add(field);
                            isSortableField.put(field, mapSObjectField.get(field).getDescribe().isSortable());
                        }
                        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);
                    }
                    } catch (Exception e) {}                  
                } else if(sObjectFields != null) {
                    //load field sortables and do not sortables
                    for(String f : sObjectFields) { 
                        isSortableField.put(f, mapSObjectField.get(f).getDescribe().isSortable());
                    }                            
                    doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);
                }
            }  
        }
    }
    
    private Integer sp;
    //pagination variables 
    private Integer pageNumber;
    public Integer recordsTotal{get;set;}
    public Integer totalPages{get;set;}
    //pagination variables
    
    public List<SObject> resultObject {get;set;}//for the results of a query
    public String getQuery {get;set;}//for build a query
    public map<String , String> mapFieldToShow{get;set;}//for to show a label of a field in the column
    private map<String, Schema.SObjectField> mapSObjectField;//for to save the SObjectField of a field
    private Schema.SObjectType sObjType;//for give fieldSets I initialize in the getFieldsMap method    
    public map<string, Boolean> isSortableField {get; set;}//for to save datas when a field is or not sortable
    public String objectNameLabel {get; set;}
    //variables for search 
    public String restQuery{get;set;}//for recover the serach critery 
    public List<SObject> resultListQuerySOSL{get; set;}//for SOSL queries
    private String sentenceWhere;//for the search with contition
    //variables for search
    
    
       
    //fields and properties for sort
    private String sortExp = 'Name';//by default will sort by Name
    public String sortDirection{get; set;}//by default ASC in constructor
    public String sortField 
    {
      get
      {
         return sortExp;
      }
      set
      {
          if(getIsSortableField(value)){
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {//other value
                sortDirection = 'DESC';
            }
            sortExp = value;
            doQuery(sObjectFields, sObjectName, sentenceWhere, sortExp, sortDirection, true);
          } else {     
        }
      }
    }
    //constructor   
    public ControllerTableObject(){
      resultObject = new List<SObject>();
      sObjectFields = new List<String>();
      resultListQuerySOSL = new List<SObject>();
      mapSObjectField = new map<String, Schema.SObjectField>();
      isSortableField = new map<String, Boolean>();
      
      sentenceWhere = null;
      sortDirection = 'ASC';
    }
    //constructor
    
    public Integer getPageNumber()
    {
        return pageNumber;
    }
    
    private Integer setupTotalPages(){
        Double num= ((recordsTotal + 0.00d) / (recordNumber + 0.00d));//pages number
        Integer pe = (Integer)num;
        double pd= num - pe;
        if(pd > 0.0) {
          pe += 1;
        }
        return pe;
    }
    
    public PageReference next(){
        
        pageNumber++;
        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);//to do a query with order by Name field
        return null;
    }
    
    public Boolean hasNext
    {        
        get{
            if(pageNumber == totalPages) {
                 return false;
            }
            return true;
        } 
    }
    
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 1) {
            return null;
        }
        
        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);
        return null;
    }
    public Boolean hasPrevious
    {        
        get{
            if(pageNumber == 1) {
                return false;
            }
            return true;
        } 
    }
    
    public PageReference first(){
        
        pageNumber = 1;
        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);//to do a query with order by Name field
        return null;
    }
    public PageReference last(){
        pageNumber = totalPages;
        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);//to do a query with order by Name field
        return null;
    }
    //pagination variables
           
    private void doQuery(List<String> queryFields, String obj, String conditionWhere, String orderByField, String sortDirection, Boolean limited) {
        
        resultObject.clear();
        getQuery = buildQuery(queryFields, obj, conditionWhere, orderByField, sortDirection, limited);
        try{
            resultObject = Database.query(getQuery);
        }catch(DMLException e){}
    } 
    
    private map<String, String> getFieldsMap(String apiNameObject) {//return a map with key API name of a field and value the label
        map<String, String> fieldToShow = new map<String, String>();
        sObjType =  Schema.getGlobalDescribe().get(apiNameObject);
        Schema.DescribeSObjectResult objDescribe = sObjType.getDescribe();
        objectNameLabel = objDescribe.getLabel();
        
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.SObjectField> tempFields = fieldMap.values();
        
        
        
        for(Schema.SObjectField sof : tempFields)
        {
           fieldToShow.put(sof.getDescribe().getName(),sof.getDescribe().getLabel());
           mapSObjectField.put(sof.getDescribe().getName(), sof);
        }            
        return fieldToShow;
    }
    
    public Boolean getIsSortableField(String field) {
      Schema.SObjectField sof = mapSObjectField.get(field);
      return sof.getDescribe().isSortable();//verify if it is a field sortable
    }
    
    private String buildQuery(List<String> queryFields, String obj, String conditionWhere, String orderByField, String sortDirection, Boolean limited){        
        String joinQueryFields = String.join(queryFields, ',');
        String query;
        
        if(joinQueryFields.contains('Id')) {
            query = 'SELECT ' + joinQueryFields;
        } else {
            query = 'SELECT Id,' + joinQueryFields;
        }
        
        query += ' FROM ' + obj;
        
        if(conditionWhere != null){
          query += ' WHERE ' + conditionWhere;
        }
        
        query += ' ORDER BY ' + orderByField + ' ' + sortDirection;
        
        if(limited){
            Integer offset = (pageNumber - 1) * recordNumber;//This operation is with gloval variables
            query += ' LIMIT '+recordNumber +' OFFSET '+ offset;
        }
                    
        return query;
    } 
    
    public PageReference searchByCritery() {
        String QueryString = 'SELECT count() FROM ' + sObjectName;
        if(String.isNotBlank(restQuery)) {
            sentenceWhere = '';
            for(String field : sObjectFields) {
                Schema.DescribeFieldResult dfr = mapSObjectField.get(field).getDescribe();
                if(dfr.isFilterable()) {
                    if(dfr.getType() == Schema.DisplayType.String) {
                        sentenceWhere += 'Name like \''+restQuery+'%\' ';
                    }
                }
            }
            //sentenceWhere = 'Name like \''+restQuery+'%\'';
            QueryString += ' WHERE ' + sentenceWhere; 
        } else {
            sentenceWhere = null;
        }
        pageNumber = 1;
        recordsTotal = Database.countQuery(QueryString);      
        totalPages = setupTotalPages();
        doQuery(sObjectFields, sObjectName, sentenceWhere, sortField, sortDirection, true);
        return null;
    }
    //new feature The task is implement a functionality to do bulk actions over the list records    
    
    @RemoteAction
    global static Boolean processChecked(List<String> arrayId) {        
        if(arrayId.isEmpty()) {
            return false;
        }
        try {
            for(String id : arrayId) {
                DataBase.delete(id);
            }
            return true;
        } catch(DmlException e) {
            return false;
        }
    }
    
    public class SelectableObject {
    }
    //new feature
}