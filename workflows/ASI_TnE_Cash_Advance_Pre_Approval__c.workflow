<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_TnE_Cash_Advance_Pre_approval_Send_Rejected_Notification</fullName>
        <description>ASI TnE Cash Advance Pre-approval Send Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_TnE_Email_Template/ASI_TnE_Cash_Adv_Pre_apprv_Rejt_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_TnE_SG_Set_Cash_Adv_Read_Only_RecTyp</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_TnE_SG_Cash_Advance_Pre_approval_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set SG Cash Adv Read Only Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Status_Approved</fullName>
        <field>ASI_TnE_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Status_Draft</fullName>
        <field>ASI_TnE_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Status_Submitted</fullName>
        <field>ASI_TnE_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Set Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Sys_Allow_Submit_Aprv_False</fullName>
        <field>ASI_TnE_Sys_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Set Sys Allow Submit Approval False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Sys_Allow_Submit_Aprv_True</fullName>
        <field>ASI_TnE_Sys_Allow_Submit_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Set Sys Allow Submit Approval True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_TH_Set_Cash_Adv_Read_Only_RecTyp</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_TnE_TH_Cash_Advance_Pre_approval_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set TH Cash Adv Read Only Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
