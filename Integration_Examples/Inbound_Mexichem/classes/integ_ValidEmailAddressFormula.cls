public with sharing class integ_ValidEmailAddressFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        
        String value = String.valueOf(externalDataMap.get(item.ExternalFieldNameTxt__c));
        
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex); 
        Matcher MyMatcher = MyPattern.matcher(value); 
        
        if (!MyMatcher.matches()) {
        	return null;     
        }else{
        	return value;    
        }
    }
}