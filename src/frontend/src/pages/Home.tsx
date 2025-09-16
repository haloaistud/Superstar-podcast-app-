import React from 'react';
import { View, Text, Button } from 'react-native';

export default function Home({ navigation }) {
  return (
    <View style={{flex:1, justifyContent:'center', alignItems:'center'}}>
      <Text>Superstar Podcast Hub Home</Text>
      <Button title="Go to Upload" onPress={()=>navigation.navigate('Upload')} />
    </View>
  );
}
