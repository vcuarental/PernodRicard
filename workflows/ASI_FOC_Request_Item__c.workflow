<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_FOC_CN_Cancel_Qty_Notify</fullName>
        <description>ASI_FOC_CN_Cancel_Qty_Notify</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_FOC_CN_Logistic_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>prc.sfdc.notification@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_FOC/ASI_FOC_CN_Cancel_Qty_Noti_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_FOC_CN_POSM_Line_Item_Approved</fullName>
        <description>ASI FOC CN POSM Line Item Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_FOC/ASI_FOC_POSM_Approved_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_FOC_CN_Special_Item_Rejected</fullName>
        <description>ASI_FOC_CN_Special_Item_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_FOC/ASI_FOC_CN_Special_Item_Reject_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_FOC_Request_Item_Approved</fullName>
        <description>Request Item Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_FOC/ASI_FOC_Brand_Director_Approved_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_FOC_Request_Item_Rejected</fullName>
        <description>Request Item Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_FOC/ASI_FOC_Brand_Director_Rejected_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_FreeGoodRequest</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_FOC_Request_Order__r.ASI_CRM_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_FreeGoodRequest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Increment_sys_changed</fullName>
        <field>ASI_SG_CRM_SYS_Changed__c</field>
        <literalValue>1</literalValue>
        <name>Increment sys changed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_BD_Approval_In_Progress</fullName>
        <field>ASI_FOC_Brand_Director_Approval_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Brand Director Approval In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_BD_Recalled</fullName>
        <field>ASI_FOC_Brand_Director_Approval_Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>ASI FOC BD Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Brand_Director_Approved</fullName>
        <field>ASI_FOC_Brand_Director_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Brand Director Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Brand_Director_Rejected</fullName>
        <field>ASI_FOC_Brand_Director_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Brand Director Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_CN_RequestAmount_Update</fullName>
        <field>ASI_FOC_Request_Quantity_Bottle__c</field>
        <formula>ASI_FOC_Original_Request_Quantity_PC_BT__c</formula>
        <name>ASI_FOC_CN_RequestAmount_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_HK_Item_Update_Is_Premium</fullName>
        <field>ASI_FOC_Is_Premium__c</field>
        <literalValue>1</literalValue>
        <name>ASI FOC HK Item Update Is Premium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Item_Check_Approval_In_Progress</fullName>
        <field>ASI_FOC_Approval_In_Progress__c</field>
        <literalValue>1</literalValue>
        <name>FOC Item Check Approval In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Item_Choose_Email_Template</fullName>
        <field>ASI_FOC_Email_Notification_Template__c</field>
        <formula>&quot;ASI_FOC_New_Approval_Alert_Brand_Director_2&quot;</formula>
        <name>FOC Item Choose Email Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Item_Uncheck_Approval_In_Progres</fullName>
        <field>ASI_FOC_Approval_In_Progress__c</field>
        <literalValue>0</literalValue>
        <name>FOC Item Uncheck Approval In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_POSM_RequestAmount_Update</fullName>
        <field>ASI_FOC_Request_Quantity_PC__c</field>
        <formula>ASI_FOC_Original_Request_Quantity_PC_BT__c</formula>
        <name>ASI_FOC_POSM_RequestAmount_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Set_Request_Item_Unique_Key</fullName>
        <field>ASI_FOC_Sys_Unique_Key__c</field>
        <formula>Name &amp; ASI_FOC_Request_Order__r.Name</formula>
        <name>ASI FOC Set Request Item Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Update_Actual_Cost</fullName>
        <field>ASI_FOC_Free_Goods_Actual_Cost__c</field>
        <formula>IF(ISPICKVAL( ASI_FOC_Request_Order__r.ASI_FOC_Request_Type__c , &quot;Return&quot; ), -1* ASI_FOC_SO_Actual_Extended_Cost__c , ASI_FOC_SO_Actual_Extended_Cost__c )</formula>
        <name>ASI FOC Update Actual Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Update_Free_Good_Cost</fullName>
        <field>ASI_FOC_Free_Good_Cost__c</field>
        <formula>IF( /*NOT(ISPICKVAL(ASI_FOC_Request_Order__r.ASI_FOC_Purpose__c, &apos;Special Promotion for Metro&apos;))*/
  ISPICKVAL(ASI_FOC_Request_Order__r.ASI_MFM_Tax_Saving_Purpose__r.ASI_CRM_Cost_Selection__c, &apos;Stock Price&apos;),
  IF(ISPICKVAL(  ASI_FOC_Request_Order__r.ASI_FOC_Request_Type__c , &quot;Return&quot; ), 
   -1*ASI_FOC_SKU__r.ASI_FOC_Stock_Price__c *  ASI_FOC_Request_Quantity_Bottle__c, 
   ASI_FOC_SKU__r.ASI_FOC_Stock_Price__c *  ASI_FOC_Request_Quantity_Bottle__c
  ), 
  IF(ISPICKVAL(  ASI_FOC_Request_Order__r.ASI_FOC_Request_Type__c , &quot;Return&quot; ), 
   -1* ASI_FOC_SKU__r.ASI_FOC_List_Price__c *  ASI_FOC_Request_Quantity_Bottle__c, 
   ASI_FOC_SKU__r.ASI_FOC_List_Price__c *  ASI_FOC_Request_Quantity_Bottle__c
  )
 )</formula>
        <name>Update Free Good Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_FOC_Update_POSM_Cost</fullName>
        <field>ASI_FOC_Free_Good_Cost__c</field>
        <formula>IF(
ISPICKVAL(  ASI_FOC_Request_Order__r.ASI_FOC_Request_Type__c , &quot;Return&quot; ), 
-1*ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Unit_Cost__c *  ASI_FOC_Request_Quantity_PC__c, 
ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Unit_Cost__c *  ASI_FOC_Request_Quantity_PC__c
)</formula>
        <name>Update POSM Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI FOC HK Item Update Is Premium</fullName>
        <actions>
            <name>ASI_FOC_HK_Item_Update_Is_Premium</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Is Premium value from SKU to Request Item</description>
        <formula>ASI_FOC_SKU__r.ASI_FOC_Is_Premium__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI FOC Set Request Item Unique Key</fullName>
        <actions>
            <name>ASI_FOC_Set_Request_Item_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN FOC Request Item</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI FOC Update Actual Free Good Cost</fullName>
        <actions>
            <name>ASI_FOC_Update_Actual_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.ASI_FOC_SO_Actual_Extended_Cost__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.ASI_FOC_Actual_Quantity_Bottle__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>HK FOC Request Item</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI FOC Update Free Good Cost</fullName>
        <actions>
            <name>ASI_FOC_Update_Free_Good_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.ASI_FOC_Request_Quantity_Bottle__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>HK FOC Request Item</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI FOC Update POSM Cost</fullName>
        <actions>
            <name>ASI_FOC_Update_POSM_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.ASI_FOC_Request_Quantity_PC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN POSM Request Item</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_FreeGoodRequestItem</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_FreeGoodRequest</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI FOC MY Request Item</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_SG_FOC_Item_Update</fullName>
        <actions>
            <name>ASI_CRM_SG_Increment_sys_changed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (  CONTAINS( RecordType.DeveloperName , &quot;ASI_SG_CRM&quot;),  ASI_FOC_Actual_Quantity_Bottle__c &gt; ASI_FOC_Request_Quantity_Bottle__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_FOC_CN_Cancel_Qty_Notify</fullName>
        <actions>
            <name>ASI_FOC_CN_Cancel_Qty_Notify</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN POSM Request Item,CN FOC Request Item</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_FOC_Request_Item__c.ASI_FOC_Cancel_Quantity_PC_BT__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
