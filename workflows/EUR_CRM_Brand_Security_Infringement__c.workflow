<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_BG_Send_BSI_to_Sales_Director</fullName>
        <description>EUR BG Send BSI to Sales Director</description>
        <protected>false</protected>
        <recipients>
            <recipient>EUR_BG_Sales_Director</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_BG_Email_Templates/EUR_BG_BSI_Notification_to_Sales_Director</template>
    </alerts>
    <alerts>
        <fullName>EUR_DB_Send_BSI_to_IT</fullName>
        <description>EUR DB Send BSI to IT</description>
        <protected>false</protected>
        <recipients>
            <recipient>aidan.mcparland@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DB_Email_Templates/EUR_DB_BSI_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_IDL_Send_BSI_to_IT</fullName>
        <description>EUR IDL Send BSI to IT</description>
        <protected>false</protected>
        <recipients>
            <recipient>shane.davey@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_IDL_Email_Templates/EUR_IDL_BSI_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_IT_Send_BSI_to_IT</fullName>
        <description>EUR IT Send BSI to IT</description>
        <protected>false</protected>
        <recipients>
            <recipient>loredana.panza@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_IT_Email_Templates/EUR_IT_BSI_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_MA_Send_BSI_to_Sales_Director</fullName>
        <description>EUR MA Send BSI to Sales Director</description>
        <protected>false</protected>
        <recipients>
            <recipient>EUR_MA_Sales_Director</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_MA_Email_Templates/EUR_MA_BSI_Notification_to_Sales_Director</template>
    </alerts>
    <alerts>
        <fullName>EUR_PT_Send_BSI_to_IT</fullName>
        <description>EUR PT Send BSI to IT</description>
        <protected>false</protected>
        <recipients>
            <recipient>joao.lopes@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lina.goncalves@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_PT_Email_Templates/EUR_PT_BSI_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_RU_Send_BSI_to_Administrator</fullName>
        <description>EUR RU Send BSI to Administrator</description>
        <protected>false</protected>
        <recipients>
            <recipient>ilya.burtsev@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_RU_Email_Templates/EUR_RU_BSI_Notification_to_Administrator</template>
    </alerts>
    <rules>
        <fullName>EUR BG New BSI Notification to Sales Director</fullName>
        <actions>
            <name>EUR_BG_Send_BSI_to_Sales_Director</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>BG</value>
        </criteriaItems>
        <description>Notify the Sales Director that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR DB New BSI Notification to IT</fullName>
        <actions>
            <name>EUR_DB_Send_BSI_to_IT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>DB</value>
        </criteriaItems>
        <description>Notify PR DB that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR IDL New BSI Notification to IT</fullName>
        <actions>
            <name>EUR_IDL_Send_BSI_to_IT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>IDL</value>
        </criteriaItems>
        <description>Notify PR IDL that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR IT New BSI Notification to IT</fullName>
        <actions>
            <name>EUR_IT_Send_BSI_to_IT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>IT</value>
        </criteriaItems>
        <description>Notify the IT that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR MA New BSI Notification to Sales Director</fullName>
        <actions>
            <name>EUR_MA_Send_BSI_to_Sales_Director</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>MA</value>
        </criteriaItems>
        <description>Notify the Sales Director that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR PT New BSI Notification to IT</fullName>
        <actions>
            <name>EUR_PT_Send_BSI_to_IT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>PT</value>
        </criteriaItems>
        <description>Notify PR PT that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR RU New BSI Notification to Administrator</fullName>
        <actions>
            <name>EUR_RU_Send_BSI_to_Administrator</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Brand_Security_Infringement__c.EUR_CRM_Country_Code__c</field>
            <operation>equals</operation>
            <value>RU</value>
        </criteriaItems>
        <description>Notify the Administrator that a new Brand Security Infringement Record has been created by SR.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
