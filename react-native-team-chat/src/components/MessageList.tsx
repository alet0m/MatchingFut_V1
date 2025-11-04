import React, { memo, useCallback } from 'react';
import { FlatList, ListRenderItem, StyleSheet, Text, View } from 'react-native';
import type { Message } from '../types/models';
import { formatRelative } from '../utils/time';

export type MessageListProps = {
  messages: Message[]; // ASC order
  currentUserId: string | null;
  onLoadMore: () => void;
  loadingMore?: boolean;
};

const MessageItem = memo(({ item, isMine, showTimestamp }: { item: Message; isMine: boolean; showTimestamp: boolean }) => {
  return (
    <View style={[styles.row, isMine ? styles.rowMine : styles.rowOther]}>
      <View style={[styles.bubble, isMine ? styles.bubbleMine : styles.bubbleOther]}>
        <Text style={[styles.content, isMine ? styles.contentMine : styles.contentOther]}>{item.content}</Text>
        {showTimestamp && (
          <Text style={styles.timestamp}>{formatRelative(item.created_at)}</Text>
        )}
      </View>
    </View>
  );
});

export function MessageList({ messages, currentUserId, onLoadMore, loadingMore }: MessageListProps) {
  const keyExtractor = useCallback((item: Message) => item.id, []);

  const renderItem: ListRenderItem<Message> = useCallback(({ item, index }) => {
    const isMine = currentUserId != null && item.user_id === currentUserId;
    // Grouping: show timestamp if previous message is from different author or >5min apart
    const prev = index > 0 ? messages[index - 1] : undefined;
    const showTimestamp = !prev || prev.user_id !== item.user_id || (new Date(item.created_at).getTime() - new Date(prev.created_at).getTime()) > 5 * 60 * 1000;
    return <MessageItem item={item} isMine={isMine} showTimestamp={showTimestamp} />;
  }, [messages, currentUserId]);

  return (
    <FlatList
      inverted
      data={messages}
      keyExtractor={keyExtractor}
      renderItem={renderItem}
      contentContainerStyle={styles.list}
      onEndReachedThreshold={0.1}
      onEndReached={() => {
        if (!loadingMore) onLoadMore();
      }}
      ListFooterComponent={loadingMore ? <Text style={styles.loadingMore}>Cargando...</Text> : null}
    />
  );
}

const styles = StyleSheet.create({
  list: {
    padding: 12,
  },
  row: {
    width: '100%',
    marginVertical: 4,
    flexDirection: 'row',
  },
  rowMine: {
    justifyContent: 'flex-end',
  },
  rowOther: {
    justifyContent: 'flex-start',
  },
  bubble: {
    maxWidth: '80%',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 14,
  },
  bubbleMine: {
    backgroundColor: '#DCF8C6',
    borderTopRightRadius: 4,
  },
  bubbleOther: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 4,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#E6E6E6',
  },
  content: {
    fontSize: 16,
  },
  contentMine: {
    color: '#1B5E20',
  },
  contentOther: {
    color: '#333',
  },
  timestamp: {
    fontSize: 11,
    color: '#999',
    marginTop: 4,
    alignSelf: 'flex-end',
  },
  loadingMore: {
    textAlign: 'center',
    color: '#666',
    paddingVertical: 12,
  },
});

export default memo(MessageList);
