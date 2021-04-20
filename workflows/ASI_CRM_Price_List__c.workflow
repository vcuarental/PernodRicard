<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_JP_DS_Price_List_Approval_Approved</fullName>
        <description>ASI CRM JP DS Price List Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_DS_Price_List_App_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_DS_Price_List_Approval_Rejected</fullName>
        <description>ASI CRM JP DS Price List Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_DS_Price_List_App_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_D_C_Price_List_Approval_Approved</fullName>
        <description>ASI CRM JP D&amp;C Price List Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_D_C_Price_List_App_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_D_C_Price_List_Approval_Rejected</fullName>
        <description>ASI CRM JP D&amp;C Price List Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_D_C_Price_List_App_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Price_List_Approval_Approved</fullName>
        <description>ASI CRM JP Price List Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_Price_List_App_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Price_List_Approval_Rejected</fullName>
        <description>ASI CRM JP Price List Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_Price_List_App_Rejected_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_WS_Price_List_Approval_Approved</fullName>
        <description>ASI CRM JP WS Price List Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_WS_Price_List_App_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_WS_Price_List_Approval_Rejected</fullName>
        <description>ASI CRM JP WS Price List Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_WS_Price_List_App_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_DC_Change_Status</fullName>
        <description>Change to another record type to limit read-only.</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_D_C_Price_List_Approved</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_DC_APPROVE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_DC_REJECTED</fullName>
        <description>Rejected to switch back to normal UI for re submission.</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_D_C_Price_List</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_DC_REJECTED</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_DS_APPROVE</fullName>
        <description>Change to this record type whenever user submitted approval request or approved.</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Direct_Sales_Price_List_Approve</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_DS_APPROVE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_DS_REJECT</fullName>
        <description>Rejected Request should return to editable</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Direct_Sales_Price_List</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_DS_REJECT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Price_List_Approved</fullName>
        <field>ASI_CRM_JP_Approved__c</field>
        <literalValue>1</literalValue>
        <name>ASI CRM JP Price List Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Price_List_Update_App_Date</fullName>
        <field>ASI_CRM_JP_Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>ASI CRM JP Price List Update App Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_WS_APPROVE</fullName>
        <description>Change to this record type to make the form read only.</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Wholesaler_FOC_on_Invoice_Price_List_Approve</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_WS_APPROVE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_WS_REJECT</fullName>
        <description>Rejected Request should change back to editable</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Wholesaler_FOC_on_Invoice_Price_List</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_JP_WS_REJECT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
