<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EXT_USR_RQT_Approved_Alert_External_User</fullName>
        <description>External User Request Approved - Alert External User</description>
        <protected>false</protected>
        <recipients>
            <field>EXT_USR_RQT_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EXT_USR_RQT_Email_Templates/EXT_USR_RQT_Email_to_the_External_User_to_sign_the_ESN_Policy</template>
    </alerts>
    <alerts>
        <fullName>EXT_USR_RQT_Approved_Alert_Owner</fullName>
        <description>External User Request Approved - Alert Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EXT_USR_RQT_Email_Templates/EXT_USR_RQT_Approved_or_Rejected_email_to_the_Employee</template>
    </alerts>
    <alerts>
        <fullName>EXT_USR_RQT_Email_External_User_for_Granted</fullName>
        <description>Email External User for Granted</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EXT_USR_RQT_Email_Templates/EXT_USR_RQT_Email_confirmation_template</template>
    </alerts>
    <alerts>
        <fullName>EXT_USR_RQT_Initial_Submission_External_User_Request_Owner_Alert</fullName>
        <description>Initial Submission External User Request - Owner Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EXT_USR_RQT_Email_Templates/EXT_USR_RQT_into_consideration</template>
    </alerts>
    <alerts>
        <fullName>EXT_USR_RQT_Refused_Alert_Owner</fullName>
        <description>External User Request Refused - Alert Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EXT_USR_RQT_Email_Templates/EXT_USR_RQT_Approved_or_Rejected_email_to_the_Employee</template>
    </alerts>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_Approved_Status</fullName>
        <description>Update the External User Request Status when the request is accepted by the manager.</description>
        <field>EXT_USR_RQT_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>External User Request Approved - Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_Created_by_Manager</fullName>
        <description>Update the field &quot;Created By&apos;s Manager&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USR_RQT_Created_By_s_Manager__c</field>
        <formula>CreatedBy.Manager.FirstName +&quot; &quot;+ CreatedBy.Manager.LastName</formula>
        <name>Update External User Request Created Mng</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU01_Update_Alias</fullName>
        <description>Update the field &quot;Alias&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USR_RQT_Alias__c</field>
        <formula>LEFT( EXT_USR_RQT_First_Name__c , 1) + LEFT(EXT_USR_RQT_Last_Name__c, 4)</formula>
        <name>Update External User Request Alias</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU01_Update_Date</fullName>
        <description>Update the field &quot;Expiry Date&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USE_RQT_Expiry_Date__c</field>
        <formula>LastModifiedDate +  EXT_USR_RQT_Expiry_Duration__c</formula>
        <name>Update External User Request Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU01_Update_Expiry_Duration</fullName>
        <description>Update the field &quot;Expiry Duration&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USR_RQT_Expiry_Duration__c</field>
        <formula>90</formula>
        <name>Update External User Request Expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU01_Update_Nickname</fullName>
        <description>Update the field &quot;Community Nickname&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USR_RQT_Community_Nickname__c</field>
        <formula>LEFT( EXT_USR_RQT_Email__c , FIND(&quot;@&quot;, EXT_USR_RQT_Email__c) -1) +  RIGHT( Name , 4)</formula>
        <name>Update External User Request Nickname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU01_Update_Username</fullName>
        <description>Update the field &quot;Username&quot; on records related to &quot;External User Request&quot;.</description>
        <field>EXT_USR_RQT_Username__c</field>
        <formula>LEFT( EXT_USR_RQT_Email__c ,  FIND(&quot;@&quot;, EXT_USR_RQT_Email__c) ) +&quot;guest.pernod-ricard.com&quot;</formula>
        <name>Update External User Request Username</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_FU02_Update_Status</fullName>
        <field>EXT_USR_RQT_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update External User Request Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_Refused_Status</fullName>
        <description>When the External User Request is refused, change the status to &quot;Refused&quot;.</description>
        <field>EXT_USR_RQT_Status__c</field>
        <literalValue>Refused</literalValue>
        <name>External User Request Refused - Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXT_USR_RQT_Submission_status</fullName>
        <description>Change the external user request status to &quot;pending&quot;.</description>
        <field>EXT_USR_RQT_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>External user Request Initial Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EXT_USR_RQT_WF01_Update_Fields</fullName>
        <actions>
            <name>EXT_USR_RQT_Created_by_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXT_USR_RQT_FU01_Update_Alias</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXT_USR_RQT_FU01_Update_Nickname</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXT_USR_RQT_FU01_Update_Username</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>External_User_Request__c.EXT_USR_RQT_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>External_User_Request__c.EXT_USR_RQT_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>This workflow will modify all the following fields to fulfill the right information, based on formula.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EXT_USR_RQT_WF02_Update_Fields</fullName>
        <actions>
            <name>EXT_USR_RQT_Email_External_User_for_Granted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EXT_USR_RQT_FU02_Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>External_User_Request__c.EXT_USR_RQT_External_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>External_User_Request__c.EXT_USR_RQT_Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow will modify the status of a External User Request.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
