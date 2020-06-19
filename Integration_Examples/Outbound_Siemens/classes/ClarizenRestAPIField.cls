/*
Name: ClarizenRestAPIField
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Class used for the integration fields mapping.
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPIField {
	private String value;
    private boolean quoted;
    
    public ClarizenRestAPIField(String value, boolean quoted) {
        this.value = value;
        this.quoted = quoted;
    }

    public String getValue() { return this.value; }
    
    public void setValue(String value) { this.value = value; }
    
    public boolean isQuoted() { return this.quoted; }
}