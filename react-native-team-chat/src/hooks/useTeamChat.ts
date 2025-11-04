import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { RealtimePostgresInsertPayload } from '@supabase/supabase-js';
import type { Message } from '../types/models';

// Helper to parse DB row to Message
function mapMessage(row: any): Message {
  return {
    id: row.id as string,
    team_id: row.team_id as string,
    user_id: row.user_id as string,
    content: row.content as string,
    created_at: row.created_at as string,
    edited_at: row.edited_at ?? null,
  };
}

export function useTeamChat(teamId: string) {
  const [messages, setMessages] = useState<Message[]>([]); // stored ASC by created_at
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);

  const loadingRef = useRef(false);
  const newestCursor = useMemo(() => messages.at(-1)?.created_at, [messages]);
  const oldestCursor = useMemo(() => messages[0]?.created_at, [messages]);

  const loadInitial = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('team_id', teamId)
        .order('created_at', { ascending: false })
        .limit(50);
      if (error) throw error;
  const rows: Message[] = (data ?? []).map(mapMessage);
      // We want ASC order in state (oldest -> newest) for nicer operations
  const asc = rows.sort((a: Message, b: Message) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
      setMessages(asc);
      setHasMore(rows.length === 50);
    } catch (e: any) {
      setError(e.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }, [teamId]);

  const loadMore = useCallback(async () => {
    if (loadingRef.current || !hasMore || !oldestCursor) return;
    loadingRef.current = true;
    setLoadingMore(true);
    try {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('team_id', teamId)
        .lt('created_at', oldestCursor)
        .order('created_at', { ascending: false })
        .limit(50);
      if (error) throw error;
  const rows: Message[] = (data ?? []).map(mapMessage);
  const asc = rows.sort((a: Message, b: Message) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
  setMessages((prev: Message[]) => [...asc, ...prev]);
      setHasMore(rows.length === 50);
    } catch (e: any) {
      setError(e.message ?? String(e));
    } finally {
      setLoadingMore(false);
      loadingRef.current = false;
    }
  }, [teamId, oldestCursor, hasMore]);

  const subscribeRealtime = useCallback(() => {
    const channel = supabase
      .channel(`messages:team:${teamId}`)
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `team_id=eq.${teamId}`,
      }, (payload: RealtimePostgresInsertPayload<any>) => {
        const row = payload.new as any;
        const msg = mapMessage(row);
        setMessages((prev: Message[]) => {
          if (prev.find((m: Message) => m.id === msg.id)) return prev; // de-dupe
          // Insert keeping ASC order
          const idx = prev.findIndex((m: Message) => new Date(m.created_at).getTime() > new Date(msg.created_at).getTime());
          if (idx === -1) return [...prev, msg];
          const clone = prev.slice();
          clone.splice(idx, 0, msg);
          return clone;
        });
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [teamId]);

  const send = useCallback(async (content: string) => {
    const trimmed = content.trim();
    if (!trimmed) return;
    // Optimistic UI: add temp message
    const tempId = `temp-${Date.now()}`;
    const temp: Message = {
      id: tempId,
      team_id: teamId,
      user_id: 'me', // overwritten by realtime insert
      content: trimmed,
      created_at: new Date().toISOString(),
      edited_at: null,
    };
  setMessages((prev: Message[]) => [...prev, temp]);

    try {
      const { data, error } = await supabase.rpc('send_team_message', {
        p_team: teamId,
        p_content: trimmed,
      });
      if (error) throw error;
      // We don't need to replace temp: realtime INSERT will add the real message.
      // Optionally, remove temp after a timeout if realtime is slow.
      setTimeout(() => {
        setMessages((prev: Message[]) => prev.filter((m: Message) => m.id !== tempId));
      }, 1500);
      return data as string | null;
    } catch (e: any) {
      // On error, remove temp and surface message
  setMessages((prev: Message[]) => prev.filter((m: Message) => m.id !== tempId));
      if (typeof e.message === 'string') {
        if (e.message.includes('rate limited')) throw new Error('Estás enviando mensajes muy rápido. Intenta en unos segundos.');
        if (e.message.includes('banned content')) throw new Error('Tu mensaje contiene palabras no permitidas.');
        if (e.message.includes('not a team member')) throw new Error('No eres miembro del equipo.');
      }
      throw e;
    }
  }, [teamId]);

  useEffect(() => {
    loadInitial();
    const unsub = subscribeRealtime();
    return () => {
      unsub?.();
    };
  }, [loadInitial, subscribeRealtime]);

  return {
    messages, // ASC
    loading,
    loadingMore,
    error,
    hasMore,
    loadInitial,
    loadMore,
    send,
  };
}
