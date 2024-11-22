const admin = require("firebase-admin");
const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
admin.initializeApp();

// Notificação de Nova Mensagem
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

    const title = "Nova Mensagem";
    const body = `Você recebeu uma mensagem de ${senderName}.`;
    const icon = "assets/new_message_icon.png";

    if (deviceToken) {
        const message = {
            notification: { title, body },
            android: {
                notification: {
                    icon,
                },
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

    try {
        await admin.firestore().collection("notifications").add({
            userId: receiverId,
            title,
            body,
            icon,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            isUnread: true,
        });
        console.log("Notificação armazenada com sucesso.");
    } catch (error) {
        console.error("Erro ao armazenar a notificação:", error);
    }
});

// Notificação de Novo Pedido de Troca
exports.notifyNewExchangeRequest = onDocumentCreated("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    const ownerId = requestData.ownerId;
    const requestedBookTitle = requestData.requestedBook?.title || "Livro";

    const title = "Nova Solicitação de Troca";
    const body = `Seu livro "${requestedBookTitle}" recebeu uma oferta de troca.`;
    const icon = "assets/new_request_icon.png";

    const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
    const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

    if (deviceToken) {
        const message = {
            notification: { title, body },
            android: {
                notification: {
                    icon,
                },
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

    try {
        await admin.firestore().collection("notifications").add({
            userId: ownerId,
            title,
            body,
            icon,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            isUnread: true,
        });
        console.log("Notificação armazenada com sucesso.");
    } catch (error) {
        console.error("Erro ao armazenar a notificação:", error);
    }
});

// Notificação de Aceitação de Solicitação
exports.notifyRequestAccepted = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "Aguardando confirmação do endereço" && after.status === "Aguardando confirmação do endereço") {
        const requesterId = after.requesterId;
        const requestedBookTitle = after.requestedBook?.title || "Livro";

        const title = "Pedido Aceito";
        const body = `Seu pedido de troca pelo livro "${requestedBookTitle}" foi aceito!`;
        const icon = "assets/acceptance_request_icon.png";

        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        if (deviceToken) {
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
                },
                token: deviceToken,
            };

            try {
                await admin.messaging().send(message);
                console.log("Notificação de pedido de aceite enviada.");
            } catch (error) {
                console.error("Erro ao enviar notificação de aceite:", error);
            }
        }

        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Notificação de Rejeição de Pedido de Troca
exports.notifyRequestRejected = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    if (requestData.status === "pending") {
        const requesterId = requestData.requesterId;
        const requestedBookTitle = requestData.requestedBook?.title || "Livro";

        const title = "Pedido Rejeitado";
        const body = `Seu pedido de troca pelo livro "${requestedBookTitle}" foi rejeitado.`;
        const icon = "assets/rejected_request_icon.png";

        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        if (deviceToken) {
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Notificação de Endereço Definido
exports.notifyAddressDefined = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "Aguardando recebimento" && after.status === "Aguardando recebimento") {
        const requesterId = after.requesterId;

        // Obter o token do requester
        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        const title = "Endereço Definido";
        const body = `O endereço para sua troca foi definido. Verifique os detalhes na aba Trocas em Andamentos.`;
        const icon = "assets/set_address_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Notificação de Mudança de Endereço
exports.notifyAddressChange = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Verificar status e mudança no comprimento do campo address
    const beforeAddress = Array.isArray(before.deliveryAddress) ? before.deliveryAddress : [];
    const afterAddress = Array.isArray(after.deliveryAddress) ? after.deliveryAddress : [];

    if (beforeAddress.length + 1 === afterAddress.length && beforeAddress.length !== 0) {
        const requesterId = after.requesterId;

        // Obter o token do requester
        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        const title = "Mudança de Endereço";
        const body = `O endereço para sua troca foi mudado. Verifique os detalhes na aba Trocas em Andamento.`;
        const icon = "assets/set_address_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
                },
                token: deviceToken,
            };

            try {
                await admin.messaging().send(message);
                console.log("Notificação de mudança de endereço enviada.");
            } catch (error) {
                console.error("Erro ao enviar notificação de endereço:", error);
            }
        }

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Notificação de Cancelamento pelo requester após Endereço Definido
exports.notifyRequesterCancellation = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Verificar se a troca foi finalizada com divergência (não enviar notificação neste caso)
    if (
        before.status === "Aguardando recebimento" &&
        after.status === "Finalizado com divergência"
    ) {
        console.log("Troca finalizada com divergência. Notificação não enviada.");
        return;
    }

    // Verificar se o requester cancelou a troca
    if (
        before.requesterConfirmationStatus !== "cancelado" &&
        after.requesterConfirmationStatus === "cancelado" &&
        after.status === "Aguardando recebimento"
    ) {
        // Evitar notificação se o owner já confirmou o status
        if (before.ownerConfirmationStatus === "confirmado") {
            console.log("Owner já confirmou. Notificação de cancelamento não enviada.");
            return;
        }

        const ownerId = after.ownerId;

        // Obter o token do owner
        const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
        const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

        const title = "Troca Cancelada";
        const body = `A troca pelo seu livro "${after.requestedBook?.title}" foi cancelada.`;
        const icon = "assets/rejected_request_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: ownerId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Notificação de Cancelamento pelo owner após Endereço Definido
exports.notifyOwnerCancellation = onDocumentUpdated("requests/{requestId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Verificar se a troca foi finalizada com divergência (não enviar notificação neste caso)
    if (
        before.status === "Aguardando recebimento" &&
        after.status === "Finalizado com divergência"
    ) {
        console.log("Troca finalizada com divergência. Notificação não enviada.");
        return;
    }

    // Verificar se o owner cancelou a troca
    if (
        before.ownerConfirmationStatus !== "cancelado" &&
        after.ownerConfirmationStatus === "cancelado" &&
        after.status === "Aguardando recebimento"
    ) {
        // Evitar notificação se o requester já confirmou o status
        if (before.requesterConfirmationStatus === "confirmado") {
            console.log("Requester já confirmou. Notificação de cancelamento não enviada.");
            return;
        }

        const requesterId = after.requesterId;

        // Obter o token do requester
        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        const title = "Troca Cancelada";
        const body = `O proprietário do livro "${after.requestedBook?.title}" cancelou a troca.`;
        const icon = "assets/rejected_request_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});


// Cancelamento pelo requester antes do Endereço Definido
exports.notifyRequesterCancellationBeforeAddress = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    // Verificar se o campo address está vazio
    const address = Array.isArray(requestData.address) ? requestData.address : [];
    if (address.length === 0 && requestData.status !== 'pending') {
        const ownerId = requestData.ownerId;
        const requestedBookTitle = requestData.requestedBook?.title || "Livro";

        // Obter o token do owner
        const ownerDoc = await admin.firestore().collection("users").doc(ownerId).get();
        const deviceToken = ownerDoc.exists ? ownerDoc.data().deviceToken : null;

        const title = "Troca Cancelada";
        const body = `A troca pelo livro "${requestedBookTitle}" foi cancelada.`;
        const icon = "assets/rejected_request_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: ownerId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});

// Cancelamento pelo owner antes do Endereço Definido
exports.notifyOwnerCancellationBeforeAddress = onDocumentDeleted("requests/{requestId}", async (event) => {
    const requestData = event.data.data();

    // Verificar se o campo address está vazio
    const address = Array.isArray(requestData.address) ? requestData.address : [];
    if (address.length === 0 && requestData.status !== 'pending') {
        const requesterId = requestData.requesterId;
        const requestedBookTitle = requestData.requestedBook?.title || "Livro";

        // Obter o token do requester
        const requesterDoc = await admin.firestore().collection("users").doc(requesterId).get();
        const deviceToken = requesterDoc.exists ? requesterDoc.data().deviceToken : null;

        const title = "Troca Cancelada";
        const body = `A troca pelo livro "${requestedBookTitle}" foi cancelada.`;
        const icon = "assets/rejected_request_icon.png"; // Caminho ou URL do ícone

        if (deviceToken) {
            // Enviar a notificação push
            const message = {
                notification: { title, body },
                android: {
                    notification: {
                        icon,
                    },
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

        // Salvar a notificação no Firestore
        try {
            await admin.firestore().collection("notifications").add({
                userId: requesterId,
                title,
                body,
                icon, // Adicionando o campo do ícone
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isUnread: true,
            });
            console.log("Notificação armazenada com sucesso.");
        } catch (error) {
            console.error("Erro ao armazenar a notificação:", error);
        }
    }
});
