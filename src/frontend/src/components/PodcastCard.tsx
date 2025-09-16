import React from 'react';
import { View, Text } from 'react-native';

export default function PodcastCard({title}) {
  return (
    <View style={{padding:10, margin:5, borderWidth:1}}>
      <Text>{title}</Text>
    </View>
  );
}
