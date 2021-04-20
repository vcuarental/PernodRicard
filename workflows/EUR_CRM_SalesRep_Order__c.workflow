<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_DE_Free_Goods_SR_Stock_Send_Email_Notification_to_CS</fullName>
        <description>EUR DE Free Goods SR Stock Send Email Notification to CS</description>
        <protected>false</protected>
        <recipients>
            <recipient>EUR_DE_Off_Trade_CSR_Edeka</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DE_Email_Template/EUR_DE_Free_Goods_to_SR_VF</template>
    </alerts>
    <alerts>
        <fullName>EUR_DK_Free_Goods_Order_to_SR_Stock_Notification_to_CS_and_SM</fullName>
        <description>EUR DK - Free Goods Order to SR Stock - Notification to CS and SM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>EUR_DK_Customer_Services</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <field>EUR_CRM_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DK_Email_Templates/EUR_DK_FreeGoodSR_Notif_to_CSandSM</template>
    </alerts>
    <alerts>
        <fullName>EUR_DK_Free_Goods_Order_to_SR_Stock_Status_Change_Notification_to_SR</fullName>
        <description>EUR DK - Free Goods Order to SR Stock - Status Change - Notification to SR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DK_Email_Templates/EUR_DK_Free_Goods_Order_to_SR_Stock_Change_Notification_to_SR</template>
    </alerts>
    <fieldUpdates>
        <fullName>EUR_DE_SM_Approved_Free_Goods_SR_Order</fullName>
        <description>When SM rejects the Free Goods SR Order, the Order Status will be set to Draft</description>
        <field>EUR_CRM_Order_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>EUR DE SM Approved Free Goods SR Order</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DE_Set_Approval_Status_to_Approved</fullName>
        <description>When the Sales Rep Order has been approved by the SM, the approval status field will be set to Approved</description>
        <field>EUR_CRM_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>EUR DE Set Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DE_Set_Approval_Status_to_Rejected</fullName>
        <description>When the Sales Rep Order has been rejected by the SM, the approval status field will be set to Rejected</description>
        <field>EUR_CRM_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>EUR DE Set Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DE_Set_Approval_Status_to_Submitted</fullName>
        <description>When a Sales Rep Order has been submitted for approval the Approval Status field will be set to Submitted</description>
        <field>EUR_CRM_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>EUR DE Set Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DE_Set_Order_Status_to_Draft</fullName>
        <description>When a Sales Rep Order has been rejected by the SM, it&apos;s order status will be set back to Draft</description>
        <field>EUR_CRM_Order_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>EUR DE Set Order Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR DK - Free Goods Order to SR Stock - Notification to CS and SM</fullName>
        <actions>
            <name>EUR_DK_Free_Goods_Order_to_SR_Stock_Notification_to_CS_and_SM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SalesRep_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK Free Goods Order to SR Stock</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SalesRep_Order__c.EUR_CRM_Order_Status__c</field>
            <operation>equals</operation>
            <value>In Process</value>
        </criteriaItems>
        <description>Notify the Customer Service and Sales Manager that a new Free Good Order to SR Stock has been created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR DK - Free Goods Order to SR Stock - Status Change - Notification to SR</fullName>
        <actions>
            <name>EUR_DK_Free_Goods_Order_to_SR_Stock_Status_Change_Notification_to_SR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SalesRep_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK Free Goods Order to SR Stock</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SalesRep_Order__c.EUR_CRM_Order_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Notify the Sales Rep that the Free Good Order Details (Status) have been modified (Free Goods Order to SR Stock)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
