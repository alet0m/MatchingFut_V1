import React, { useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { supabase } from '../lib/supabase';
import { useTeamChat } from '../hooks/useTeamChat';
import MessageList from '../components/MessageList';
import MessageInput from '../components/MessageInput';

export type TeamChatScreenProps = {
  teamId: string;
};

export function TeamChatScreen({ teamId }: TeamChatScreenProps) {
  const [userId, setUserId] = useState<string | null>(null);
  const { messages, loading, loadingMore, error, hasMore, loadMore, send } = useTeamChat(teamId);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }: any) => {
      setUserId(data.session?.user.id ?? null);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_event: any, session: any) => {
      setUserId(session?.user.id ?? null);
    });
    return () => { sub.subscription.unsubscribe(); };
  }, []);

  const onLoadMore = useMemo(() => (hasMore ? loadMore : () => {}), [hasMore, loadMore]);

  if (error) {
    return (
      <SafeAreaView style={styles.container}>
        <Text style={styles.title}>Chat de equipo</Text>
        <View style={styles.center}> 
          <Text style={styles.error}>Error: {error}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Chat de equipo</Text>
      <View style={styles.content}>
        {loading ? (
          <View style={styles.center}><ActivityIndicator /></View>
        ) : messages.length === 0 ? (
          <View style={styles.center}><Text style={styles.empty}>Aún no hay mensajes</Text></View>
        ) : (
          <MessageList messages={messages} currentUserId={userId} onLoadMore={onLoadMore} loadingMore={loadingMore} />
        )}
      </View>
  <MessageInput onSend={async (c: string) => { await send(c); }} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f7f7f7' },
  title: { fontSize: 18, fontWeight: '700', paddingHorizontal: 16, paddingTop: 8, color: '#1B5E20' },
  content: { flex: 1 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  empty: { color: '#666' },
  error: { color: 'crimson' },
});

export default TeamChatScreen;
