import React, { useEffect, useMemo, useState } from 'react';
import { SafeAreaView, View, Text, TextInput, StyleSheet, ActivityIndicator, Platform } from 'react-native';
import { supabase } from './src/lib/supabase';
import LoginScreen from './src/screens/LoginScreen';
import TeamChatScreen from './src/screens/TeamChatScreen';

export default function App() {
  const [sessionReady, setSessionReady] = useState(false);
  const [authed, setAuthed] = useState(false);
  const [teamId, setTeamId] = useState<string>(process.env.EXPO_PUBLIC_TEAM_ID as string | undefined || '');

  useEffect(() => {
    let unsub: any;
    supabase.auth.getSession().then(({ data }) => {
      setAuthed(!!data.session);
      setSessionReady(true);
    });
    const sub = supabase.auth.onAuthStateChange((_event, sess) => {
      setAuthed(!!sess);
    });
    unsub = sub.data.subscription;
    return () => {
      unsub?.unsubscribe?.();
    };
  }, []);

  const canEnterChat = authed && teamId && teamId.length > 0;

  if (!sessionReady) {
    return (
      <SafeAreaView style={styles.center}> 
        <ActivityIndicator />
      </SafeAreaView>
    );
  }

  if (!authed) {
    return <LoginScreen />;
  }

  if (!teamId) {
    return (
      <SafeAreaView style={styles.container}>
        <Text style={styles.title}>Team Chat</Text>
        <View style={styles.box}>
          <Text style={styles.label}>Ingresa el Team ID</Text>
          <TextInput
            value={teamId}
            onChangeText={setTeamId}
            placeholder="uuid del team"
            autoCapitalize="none"
            autoCorrect={false}
            style={styles.input}
          />
          <Text style={styles.hint}>También puedes definir EXPO_PUBLIC_TEAM_ID para saltarte este paso.</Text>
        </View>
      </SafeAreaView>
    );
  }

  return <TeamChatScreen teamId={teamId} />;
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f7f7f7', padding: 16 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 20, fontWeight: '700', color: '#1B5E20', marginBottom: 12 },
  box: { backgroundColor: 'white', padding: 12, borderRadius: 8 },
  label: { fontWeight: '600', marginBottom: 8 },
  input: { borderWidth: 1, borderColor: '#ddd', borderRadius: 6, padding: 10, backgroundColor: 'white' },
  hint: { marginTop: 8, color: '#666' },
});
