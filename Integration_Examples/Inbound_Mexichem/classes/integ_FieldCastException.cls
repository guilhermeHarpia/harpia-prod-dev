public with sharing class integ_FieldCastException extends Exception {
    
/*    public integ_FieldCastException(String fieldName, String type,  String message){
		this.setMessage('Field ' + fieldName + ' can\'t cast to ' + type + '. \n' + message);	
    }

	public integ_FieldCastException(String fieldName, String type,  String message, String stackTrace){
		this.setMessage('Field ' + fieldName + ' can\'t cast to ' + type + '. \n' + message + '\n' + stackTrace);	
    }
*/
    public integ_FieldCastException(Exception ex, String fieldName, String type, String message, Integer rowNumber){
		this.initCause(ex);
		this.setMessage('Field ' + fieldName + ' can\'t cast to ' + type + '. \n' + message + '\n Record number: [' + rowNumber + ']');	
    }
    
}