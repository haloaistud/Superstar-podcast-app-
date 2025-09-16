import React from 'react';
import { View, Text, Button, Alert } from 'react-native';

export default function Upload() {
  const handleUpload = () => Alert.alert('Upload placeholder');
  return (
    <View style={{flex:1, justifyContent:'center', alignItems:'center'}}>
      <Text>Upload Podcast</Text>
      <Button title="Upload" onPress={handleUpload}/>
    </View>
  );
}
