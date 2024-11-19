const admin = require("firebase-admin");
const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
admin.initializeApp();

//Notificação de Nova Mensagem
exports.notifyMessageReceived = onDocumentCreated("messages/{messageId}", async (event) => {
    const messageData = event.data.data();

    const receiverId = messageData.receiverId;
    const senderId = messageData.senderId;

    // Busca o nome do remetente na coleção 'users'
    const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Usuário";

    // Obter o token FCM do destinatário
    const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
    const deviceToken = receiverDoc.exists ? receiverDoc.data().deviceToken : null;

    if (deviceToken) {
      const message = {
        notification: {
          title: "Nova Mensagem",
          body: `Você recebeu uma mensagem de ${senderName}.`,
        },
        token: deviceToken,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notificação de mensagem enviada.");
      } catch (error) {
        console.error("Erro ao enviar notificação de mensagem:", error);
      }
    }
  });

// Notificação de Novo Pedido de Troca
exports.notifyNewExchangeRequest = onDocumentCreated("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    const ownerId = requestData.ownerId;
    const requestedBookTitle = requestData.requestedBook?.title || "Livro";

    // Obter o token FCM do proprietário do livro
    const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
    const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

    if (deviceToken) {
      const message = {
        notification: {
          title: "Nova Solicitação de Troca",
          body: `Seu livro "${requestedBookTitle}" recebeu uma oferta de troca. Verifique na aba 'Trocas Pendentes'.`,
        },
        token: deviceToken,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notificação de pedido de troca enviada.");
      } catch (error) {
        console.error("Erro ao enviar notificação de troca:", error);
      }
    }
  });


//Notificação de Aceitação de Solicitação
exports.notifyRequestAccepted = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Verifica se o status mudou para "Aguardando confirmação do endereço"
    if (before.status !== "Aguardando confirmação do endereço" && after.status === "Aguardando confirmação do endereço") {
      const requesterId = after.requesterId;
      const requestedBookTitle = after.requestedBook?.title || "Livro";

      // Obter o token FCM do solicitante
      const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
      const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

      if (deviceToken) {
        const message = {
          notification: {
            title: "Pedido Aceito",
            body: `Seu pedido de troca pelo livro "${requestedBookTitle}" foi aceito!`,
          },
          token: deviceToken,
        };

        try {
          await admin.messaging().send(message);
          console.log("Notificação de aceitação enviada.");
        } catch (error) {
          console.error("Erro ao enviar notificação de aceitação:", error);
        }
      }
    }
  });

// Notificação de Rejeição de Pedido de Troca
exports.notifyRequestRejected = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    if (requestData.status === "pending") {
      const requesterId = requestData.requesterId;
      const requestedBookTitle = requestData.requestedBook?.title || "Livro";

      // Obter o token do requester
      const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
      const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

      if (deviceToken) {
        const message = {
          notification: {
            title: "Pedido Rejeitado",
            body: `Seu pedido de troca pelo livro "${requestedBookTitle}" foi rejeitado.`,
          },
          token: deviceToken,
        };

        try {
          await admin.messaging().send(message);
          console.log("Notificação de rejeição enviada.");
        } catch (error) {
          console.error("Erro ao enviar notificação de rejeição:", error);
        }
      }
    }
  });

// Notificação de Endereço Definido
exports.notifyAddressDefined = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "Aguardando confirmação do recebimento" && after.status === "Aguardando confirmação do recebimento") {
      const requesterId = after.requesterId;

      // Obter o token do requester
      const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
      const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

      if (deviceToken) {
        const message = {
          notification: {
            title: "Endereço Definido",
            body: `Foi definido o endereço para sua troca. Verifique os detalhes na aba Trocas em Andamento.`,
          },
          token: deviceToken,
        };

        try {
          await admin.messaging().send(message);
          console.log("Notificação de endereço definida enviada.");
        } catch (error) {
          console.error("Erro ao enviar notificação de endereço:", error);
        }
      }
    }
  });

//Notificação de Cancelamento pelo requester após Endereço Definido
exports.notifyRequesterCancellation = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.requesterConfirmationStatus !== "cancelado" && after.requesterConfirmationStatus === "cancelado" && after.status === "Aguardando confirmação do recebimento") {
      const ownerId = after.ownerId;

      // Obter o token do owner
      const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
      const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

      if (deviceToken) {
        const message = {
          notification: {
            title: "Troca Cancelada",
            body: `A troca pelo seu livro "${after.requestedBook?.title}" foi cancelada.`,
          },
          token: deviceToken,
        };

        try {
          await admin.messaging().send(message);
          console.log("Notificação de cancelamento enviada para o owner.");
        } catch (error) {
          console.error("Erro ao enviar notificação de cancelamento:", error);
        }
      }
    }
  });

//Notificação de Cancelamento pelo owner após Endereço Definido
exports.notifyOwnerCancellation = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.ownerConfirmationStatus !== "cancelado" && after.ownerConfirmationStatus === "cancelado" && after.status === "Aguardando confirmação do recebimento") {
      const requesterId = after.requesterId;

      // Obter o token do requester
      const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
      const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

      if (deviceToken) {
        const message = {
          notification: {
            title: "Troca Cancelada",
            body: `O proprietário do livro,"${after.requestedBook?.title}" cancelou a troca.`,
          },
          token: deviceToken,
        };

        try {
          await admin.messaging().send(message);
          console.log("Notificação de cancelamento enviada para o requester.");
        } catch (error) {
          console.error("Erro ao enviar notificação de cancelamento:", error);
        }
      }
    }
  });

//Cancelamento pelo requester antes do Endereço Definido
exports.notifyRequesterCancellationBeforeAddress = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    const ownerId = requestData.ownerId;
    const requestedBookTitle = requestData.requestedBook?.title || "Livro";

    // Obter o token do owner
    const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
    const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

    if (deviceToken) {
      const message = {
        notification: {
          title: "Troca Cancelada",
          body: `A troca pelo livro "${requestedBookTitle}" foi cancelada.`,
        },
        token: deviceToken,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notificação de cancelamento antes do endereço enviada para o owner.");
      } catch (error) {
        console.error("Erro ao enviar notificação de cancelamento antes do endereço:", error);
      }
    }
  });

// Cancelamento pelo owner antes do Endereço Definido
exports.notifyOwnerCancellationBeforeAddress = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    const requesterId = requestData.requesterId;
    const requestedBookTitle = requestData.requestedBook?.title || "Livro";

    // Obter o token do requester
    const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
    const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

    if (deviceToken) {
      const message = {
        notification: {
          title: "Troca Cancelada pelo Proprietário",
          body: `A troca pelo livro "${requestedBookTitle}" foi cancelada.`,
        },
        token: deviceToken,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notificação de cancelamento antes do endereço enviada para o requester.");
      } catch (error) {
        console.error("Erro ao enviar notificação de cancelamento antes do endereço:", error);
      }
    }
  });
