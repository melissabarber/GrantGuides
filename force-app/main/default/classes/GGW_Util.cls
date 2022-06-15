
/**
 * GGW_Util class for support utility methods on Grant application.
 * Used by standard and Custom controller
 * 
 * @author Igor Androsov
 * @version 1.0
 */
public class GGW_Util {
    // Pass Grant application ID record
    // return a list of selected Items (sections+blocks)
    public static List<GGW_Selected_Item__c> getSelectedItems(String appId) {
        system.debug('### Grant ID:'+appId);
        List<GGW_Selected_Item__c> items = new List<GGW_Selected_Item__c>();
        items = [SELECT Id, Name, Application_Name__c, Grant_Application__c, Selected_Block__c, 
                        GGW_Section__c, Section_Name__c, Text_Block__c,  Sort_Order__c
                        FROM GGW_Selected_Item__c WHERE Grant_Application__c =: appId ORDER BY Sort_Order__c];
        return items;
    }
    // Save Grant state for User
    public static void saveGrantState(String grantId){
        GGW_Grant_State__c st = getGrantState();
        if(st != null && st.Id != null){
            // Update existing single state
            st.Grant_Application__c = grantId;
            update st;
        }else{
            st = new GGW_Grant_State__c();
            st.Current_User__c = UserInfo.getUserId(); // save state for current user
            st.Grant_Application__c = grantId;
            insert st;
        }
    }
    // Get state
    public static GGW_Grant_State__c getGrantState(){
        List<GGW_Grant_State__c> lst = [SELECT Id, Current_User__c, Grant_Application__c 
                                    FROM GGW_Grant_State__c WHERE Current_User__c =:UserInfo.getUserId()];
        GGW_Grant_State__c grant = new GGW_Grant_State__c();                
        if(lst != null && lst.size()>0){
            grant = lst[0];
        }
        return grant;
    }
}