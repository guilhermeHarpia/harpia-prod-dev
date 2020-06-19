public with sharing class IdUtil {
	
	public static String convert15To18CharId(String id){
	    	
	     if (id == null){ 
	          return null;
	     }
	     if (id.length() != 15) {
	          return null;
	     }
	     string suffix = '';
	     integer flags;
			
	     for (integer i = 0; i < 3; i++) {
	          flags = 0;
	          for (integer j = 0; j < 5; j++) {
	               string c = id.substring(i * 5 + j,i * 5 + j + 1);
	               //Only add to flags if c is an uppercase letter:
	               if (c.toUpperCase().equals(c) && c >= 'A' && c <= 'Z') {
	                    flags = flags + (1 << j);
	               }
	          }
	          if (flags <= 25) {
	               suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(flags,flags+1);
	          }else{
	               suffix = suffix + '012345'.substring(flags-25,flags-24);
	          }
	     }
	     return id + suffix;
	}
    
    public static String generateUUID() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
    }
	
}