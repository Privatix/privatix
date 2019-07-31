# Offering template scheme fields



<table>
  <thead>
    <tr>
      <th style="text-align:left"><b>Field name</b>
      </th>
      <th style="text-align:left"><b>Field type</b>
      </th>
      <th style="text-align:left"><b>Description</b>
      </th>
      <th style="text-align:left"><b>Allow null</b>
      </th>
      <th style="text-align:left"><b>Example</b>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left"><b>agentPublicKey</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">Agent&apos;s public key</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">04a34b99f22c790c4e36b2b3c2c35a36db0
        <br />6226e41c692fc82b8b56ac1c540c5bd5b8d
        <br />ec5235a0fa8722476c7709c02559e3aa73a
        <br />a03918ba2d492eea75abea235</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>templateHash</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">Hash of corresponding template that was used to fill this message</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">
          <p>71fb09a7e9dc4fd2a85797bc92080d49ead</p>
          <p>60ebaa2b562d817bdfb31bc258134</p>
        </td>
    </tr>
    <tr>
      <td style="text-align:left"><b>country</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">Country of service endpoint in ISO 3166-1 alpha-2 format.</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">us</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>serviceSupply</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Maximum supply of services according to service offerings. It represents
        maximum number of clients that can consume this service offering concurrently.</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">5</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>unitName</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">Any semantic can be given. Can be: &quot;megabyte&quot;, &quot;gigabyte&quot;,
        etc. Used for representation only.</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">megabyte</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>unitType</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">&quot;enum&quot;:[&quot;units&quot;,&quot;seconds&quot;]</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">units</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>billingType</b>
      </td>
      <td style="text-align:left">string</td>
      <td style="text-align:left">&quot;enum&quot;: [&quot;postPaid&quot;, &quot;prepaid&quot;]</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">prepaid</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>setupPrice</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Billed once, before service usage can be started.</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">0.0000032</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>unitPrice</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">PRIX that must be paid for unit_of_service</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">0.0000002</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>minUnits</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Used to calculate minimum deposit required</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">100</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>maxUnits</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Used to specify maximum units of service that will be supplied. Can be
        empty.</td>
      <td style="text-align:left">Yes</td>
      <td style="text-align:left">10000</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>billingInterval</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Specified in unit_of_service for units OR in seconds for time-based billing.
        Represent, how often Client MUST provide payment approval to Agent.</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">50</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>maxBillingUnitLag</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Maximum payment lag in units after, which Agent will suspend service usage.</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">10</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>maxSuspendedTime</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Maximum time service can be in Suspended status due to payment lag. After
        this time period service will be terminated, if no sufficient payment was
        received. Period is specified in seconds.</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">300</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>maxInactiveTime</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Maximum time without service usage. Agent will consider, that Client will
        not use service and stop providing it. Period is specified in seconds.</td>
      <td
      style="text-align:left"></td>
        <td style="text-align:left">300</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>freeIntervals</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Used to give free trial, by specifying how many intervals can be consumed
        without payment</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">2</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>nonce</b>
      </td>
      <td style="text-align:left"></td>
      <td style="text-align:left">Random number to allow generation of identical SO with different hash.
        Possibly UUID4 generated according to RFC4122.</td>
      <td style="text-align:left"></td>
      <td style="text-align:left">ea864be6-db42-43e2-bffa-aa44ace573f0</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>additionalParams</b>
      </td>
      <td style="text-align:left"></td>
      <td style="text-align:left">Inner JSON object</td>
      <td style="text-align:left">Yes</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left"><b>&#x2192; minDownloadMbps</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Minimum expected download speed (Mbps).Can be empty.</td>
      <td style="text-align:left">Yes</td>
      <td style="text-align:left">0.2 (part of inner JSON)</td>
    </tr>
    <tr>
      <td style="text-align:left"><b>&#x2192; minUploadMbps</b>
      </td>
      <td style="text-align:left">number</td>
      <td style="text-align:left">Minimum expected upload speed (Mbps). Can be empty.</td>
      <td style="text-align:left">Yes</td>
      <td style="text-align:left">0.5 (part of inner JSON)</td>
    </tr>
  </tbody>
</table>