/*
Name: ClarizenRestAPILink
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Class used for the Clarizen entities links creation.
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPILink {
    
    private String linkUrl, parentId, childType, childId;
	
    public ClarizenRestAPILink(String linkUrl, String childType, String childId) {
        this.linkUrl = linkUrl;
        this.childType = childType;
        this.childId = childId;
    }
    
    public String getLinkUrl() { return this.linkUrl; }
    
    public String getParentId() { return this.parentId; }
    
    public void setParentId(String parentId) { this.parentId = parentId; }
    
    public String getChildType() { return this.childType; }
    
    public String getChildId() { return this.childId; }
}