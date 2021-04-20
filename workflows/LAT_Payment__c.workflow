<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_user_when_payment_gets_rejected</fullName>
        <description>Notify user when payment gets rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_Payment_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>LAT_UpdateStatusInApproval</fullName>
        <field>Status__c</field>
        <literalValue>Em Aprovação</literalValue>
        <name>Update Status In Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_field</fullName>
        <field>ApprovedPayment__c</field>
        <literalValue>1</literalValue>
        <name>Update status field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>reject</fullName>
        <field>Status__c</field>
        <literalValue>R</literalValue>
        <name>reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>reject_status</fullName>
        <field>ApprovedPayment__c</field>
        <literalValue>0</literalValue>
        <name>reject status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
