<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_CN_RentalRequestReminder_Alert</fullName>
        <description>ASI_MFM_CN_RentalRequestReminder_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_RentalRequestReminder_Temp</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_Rental_Approved_Alert</fullName>
        <description>CN Rental Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_Rental_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_Rental_Rejected_Alert</fullName>
        <description>CN Rental Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_Rental_Rejected_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_Rental_Submitted_Alert</fullName>
        <description>CN Rental Submitted Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_MFM_CN_SC_Procurement_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_Rental_Submitted_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Approval_Change_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Rental_Approval</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Approval Change RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Approval_RO_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Rental_Approval_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Approval RO RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Renovation_Change_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Renovation_Form</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Renovation Change RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Renovation_RO_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Renovation_Form_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Renovation RO RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Renovation_Req_Chg_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Renovation_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Renovation Request Change RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Renovation_Req_RO_RT</fullName>
        <description>CN Renovation Request RO</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Renovation_Request_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Renovation Request RO RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Request_Change_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Rental_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Request Change RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Request_Draft</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CN Rental Request Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Request_Final</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Final</literalValue>
        <name>CN Rental Request Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Request_RO_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Rental_Request_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Rental Request RO RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Rental_Request_Submitted</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CN Rental Request Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_RenovationRequest_Submitted_Notification_To_PMO</fullName>
        <actions>
            <name>ASI_MFM_CN_Rental_Submitted_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.ASI_MFM_ExceedAmtLimit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Renovation Request,CN Renovation Request RO</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.ASI_MFM_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Email Alert to CN PMO when Renovation Request submitted and its total amt exceeds 300K</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_RentalAppr_ReApproval</fullName>
        <actions>
            <name>ASI_MFM_CN_Rental_Approval_Change_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_MFM_CN_Rental_Request_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( ASI_MFM_Total_Contract_Amount__c ) &amp;&amp;  TEXT(ASI_MFM_Status__c) == &apos;Final&apos; &amp;&amp; (CONTAINS(RecordType.DeveloperName, &apos;ASI_MFM_CN_Rental_Approval&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_RentalRenovation_ReApproval</fullName>
        <actions>
            <name>ASI_MFM_CN_Rental_Renovation_Change_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_MFM_CN_Rental_Request_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( ASI_MFM_Total_Contract_Amount__c ) &amp;&amp;  TEXT(ASI_MFM_Status__c) == &apos;Final&apos; &amp;&amp; ( CONTAINS(RecordType.DeveloperName, &apos;ASI_MFM_CN_Renovation_Form&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_RentalRequest_Reminder</fullName>
        <actions>
            <name>ASI_MFM_CN_RentalRequestReminder_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Rental Request,CN Rental Request RO</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.ASI_MFM_Send_Email_Reminder__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_RentalRequest_Submitted_Notification_To_PMO</fullName>
        <actions>
            <name>ASI_MFM_CN_Rental_Submitted_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.ASI_MFM_ExceedRentalRequestPMOLimit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Rental Request,CN Rental Request RO</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Rental_Request__c.ASI_MFM_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Email Alert to CN PMO when Rental Request submitted and its total amt exceeds 500K</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
