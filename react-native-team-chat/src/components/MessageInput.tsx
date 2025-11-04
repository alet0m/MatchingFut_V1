import React, { memo, useCallback, useState } from 'react';
import { ActivityIndicator, Keyboard, Platform, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

export type MessageInputProps = {
  onSend: (content: string) => Promise<void> | void;
};

function MessageInputImpl({ onSend }: MessageInputProps) {
  const [value, setValue] = useState('');
  const [sending, setSending] = useState(false);

  const handleSend = useCallback(async () => {
    const trimmed = value.trim();
    if (!trimmed || sending) return;
    setSending(true);
    try {
      await onSend(trimmed);
      setValue('');
      Keyboard.dismiss();
    } catch (e: any) {
      // Show a simple toast
      console.warn(e?.message ?? String(e));
    } finally {
      setSending(false);
    }
  }, [value, onSend, sending]);

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        multiline
        placeholder="Escribe un mensaje"
        placeholderTextColor="#999"
        value={value}
        onChangeText={setValue}
        editable={!sending}
      />
      <Pressable onPress={handleSend} disabled={!value.trim() || sending} style={({ pressed }: { pressed: boolean }) => [
        styles.sendButton,
        (!value.trim() || sending) && styles.sendDisabled,
        pressed && Platform.OS === 'ios' ? { opacity: 0.7 } : null,
      ]}>
        {sending ? <ActivityIndicator color="#fff" /> : <Text style={styles.sendText}>Enviar</Text>}
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    padding: 8,
    borderTopColor: '#eee',
    borderTopWidth: StyleSheet.hairlineWidth,
    backgroundColor: '#fff',
  },
  input: {
    flex: 1,
    minHeight: 40,
    maxHeight: 140,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 12,
    backgroundColor: '#f5f6f7',
    color: '#222',
  },
  sendButton: {
    marginLeft: 8,
    backgroundColor: '#2E7D32',
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  sendDisabled: {
    backgroundColor: '#a5d6a7'
  },
  sendText: {
    color: 'white',
    fontWeight: '700',
  },
});

export const MessageInput = memo(MessageInputImpl);
export default MessageInput;
