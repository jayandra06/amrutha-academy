import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { ChatService } from '@/lib/services/chatService';

export async function GET(
  request: NextRequest,
  { params }: { params: { roomId: string } }
) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const user = await verifyFirebaseToken(token);

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const { roomId } = params;
    const hasAccess = await ChatService.checkChatRoomAccess(roomId, user.id);

    if (!hasAccess) {
      return NextResponse.json(
        createErrorResponse('Access denied', 403),
        { status: 403 }
      );
    }

    const room = await ChatService.getChatRoomById(roomId);
    const canSendMessage = room ? ChatService.canUserSendMessage(room) : false;

    return NextResponse.json(
      createSuccessResponse(
        {
          hasAccess: true,
          canSendMessage,
          status: room?.status || 'active',
          room,
        },
        200
      ),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Check chat room access error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




