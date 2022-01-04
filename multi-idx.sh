#! /bin/sh

keys=(
    "HpbSnnRPeHryHK1FFtsLcqvkWSVbRC6y1TNC4XavZavQ"
    "Dr222RSyHGKXVrWiuNgVoASrE3q9vjkJGR4QSbDiTr1L"
    "DVBNB9cT2XhHLboD2SP24W5SYpiwDDbStwU2to4oBSa5"
    "EEn732vGeoMi92H4BLxRKaSoqbyHsnRFf2sNJRHxyTgK"
    "GDCfD4cyiZTxXVw6BjKJ8KdmVDbg5ryNpeegxZs7wD4q"
    "12cWvLDjmrbLaF8kxiCwL1LjeM7iLjTCTFG48UVFqM4D"
    "GnttRVEskBUn1UsCFzmpaJYtCS5aDug9LshKRaPXyenn"
    "8RdiNDA7TJ8MmczfFtnyNVX12m5DrUV1TgczJ5eFtVCE"

)

length=${#keys[@]}

for (( i = 0; i < length; i++ ));
  do sed "s/ORACLE_KEY/${keys[$i]}/" ./switchboard-oracle/values.yaml  | sed "s/oracle-secret/oracle-secret-$i/" | cat ; #helm install oracle-idx-$i ./switchboard-oracle -f - --dry-run ;
done

#for key in ${keys[@]}; 
#  do sed "s/ORACLE_KEY/$key/" ./switchboard-oracle/values.yaml | helm install oracle-idx-$i ./switchboard-oracle -f - --dry-run ;
#  i=i+1;
#done

#echo ${keys[@]}
#sed 's/ORACLE_KEY/my-key/' values.yaml

#for i in {A..Z}; do sed "s/{{COMMAND}}/[\"bash\", \"-c\", \"python service$i.py\"]/g" values/values-service-template.yaml | helm install demo-helm-$i . -f - ; done