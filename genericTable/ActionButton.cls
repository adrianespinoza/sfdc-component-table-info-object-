global interface ActionButton {
    Boolean executeAction(String objApiName, Set<String> setIds);
    String getActionType();
}