package server;

import javafx.collections.ObservableList;
import model.*;
import model.Client;
import model.interfaces.ClientInterface;
import model.interfaces.SellerInterface;
import repository.Repository;

import com.sun.deploy.association.utility.AppConstants;

import java.io.UnsupportedEncodingException;
import java.util.*;
import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.*;
import javax.mail.internet.*;
import javax.sql.DataSource;
import java.io.*;
import java.net.Socket;
import java.util.Properties;

public class ClientHandler implements Runnable {

    private Socket socket;
    private Socket notifications;
    private String clientName;

    private ObjectInputStream in;
    private ObjectOutputStream out;

    private ObjectInputStream nin;
    private ObjectOutputStream nout;

    private boolean isStopped = false;

    private InvoiceServer server;

    private Repository repository;
    private PdfCreator pdfCreator;

    public ClientHandler(Socket socket,Socket notificatinos,String clientName,InvoiceServer server,Repository repository,PdfCreator pdfCreator) throws IOException {
        this.socket = socket;
        this.notifications = notificatinos;

        this.clientName = clientName;

        out =  new ObjectOutputStream(socket.getOutputStream());
        in =  new ObjectInputStream(socket.getInputStream());

        nout =  new ObjectOutputStream(notificatinos.getOutputStream());
        nin =  new ObjectInputStream(notificatinos.getInputStream());


        this.server = server;
        this.repository = repository;
        this.pdfCreator = pdfCreator;
    }

    @Override
    public void run() {
        System.out.println("Client thread started");
        while (!isStopped)
        {
            try
            {
                handleComands();
            }
            catch (Exception e)
            {
                System.out.println("Error in handeling commands");
            }
        }
    }

    private void handleComands() throws IOException {
        ServerCommands.COMMAND command = null;
        try {
            command = (ServerCommands.COMMAND)in.readObject();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        if(command == ServerCommands.COMMAND.SET_CLIENT_NAME)
        {
            System.out.println("Received command: " + command);
            try {
                this.clientName = in.readObject() + "-" + clientName;
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            System.out.println("ClientHandler created " + this.clientName);
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_FACTURI)
        {
            System.out.println("Received command: " + command);
            ObservableList<Factura> facturas = repository.getAllFacturi();



            out.writeObject(new ArrayList<Factura>(facturas));
            out.flush();

        }
        else  if(command == ServerCommands.COMMAND.SERIALIZE_FACTURI)
        {
            System.out.println("Received command: " + command);
            try {
                DBFactura factura = (DBFactura)in.readObject();
                repository.addNewFacturi(factura);

                server.notifyAllClients(Notifications.SERIALIZED_INVOICES + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
        else if(command == ServerCommands.COMMAND.GET_AVAILABLE_INVOICES)
        {
            System.out.println("Received command: " + command);
            try {
                Seller seller = (Seller)in.readObject();
                System.out.println(seller);
                ObservableList<InvoicesAvailable> invoicesAvailable = repository.getAvailableInvoices(seller);
                out.writeObject(invoicesAvailable.get(0));
                out.flush();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
        else if(command == ServerCommands.COMMAND.BUY_INVOICES)
        {
            System.out.println("Received command: " + command);
            try {
                InvoicesAvailable invoicesAvailable= (InvoicesAvailable) in.readObject();
                System.out.println(invoicesAvailable);
                boolean success = repository.updateBatch(invoicesAvailable);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.BUY_INVOICES + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.CLOSE)
        {
            System.out.println("Received command: " + command);
            close();
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_CLIENTS)
        {
            System.out.println("Received command: " + command);
            ArrayList<ClientInterface> clients =new ArrayList<ClientInterface>(repository.getAllClients()) ;

            out.writeObject(clients);
            out.flush();
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_PRODUCTS)
        {
            System.out.println("Received command: " + command);
            ArrayList<Product> products =new ArrayList<Product>(repository.getAllProducts()) ;

            out.writeObject(products);
            out.flush();
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_EMITORS)
        {
            System.out.println("Received command: " + command);
            ArrayList<Emitor> emitors =new ArrayList<Emitor>(repository.getAllEmitors()) ;

            out.writeObject(emitors);
            out.flush();
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_SELLERS)
        {
            System.out.println("Received command: " + command);
            ArrayList<SellerInterface> sellers =new ArrayList<SellerInterface>(repository.getAllSellers()) ;

            out.writeObject(sellers);
            out.flush();
        }
        else if(command == ServerCommands.COMMAND.GET_ALL_ACTIVITIES)
        {
            System.out.println("Received command: " + command);
            ArrayList<FacturaInfo> facturaInfos =new ArrayList<FacturaInfo>(repository.getAllActivities()) ;

            out.writeObject(facturaInfos);
            out.flush();
        }
        else if(command == ServerCommands.COMMAND.ADD_NEW_PRODUCT)
        {
            System.out.println("Received command: " + command);
            try {
                Product product = (Product)in.readObject();
                System.out.println(product);
                boolean success = repository.addNewProduct(product);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.NEW_PRODUCT_ADDED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.ADD_NEW_CLIENT)
        {
            System.out.println("Received command: " + command);
            try {
                Client client = (Client) in.readObject();
                System.out.println(client);
                boolean success = repository.addNewClient(client);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.NEW_CLIENT_ADDED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.ADD_NEW_SELLER)
        {
            System.out.println("Received command: " + command);
            try {
                Seller seller = (Seller) in.readObject();
                System.out.println(seller);
                boolean success = repository.addNewSeller(seller);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.NEW_SELLER_ADDED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.ADD_NEW_EMITOR)
        {
            System.out.println("Received command: " + command);
            try {
                Emitor emitor = (Emitor) in.readObject();
                System.out.println(emitor);
                boolean success = repository.addNewEmitor(emitor);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.NEW_EMITOR_ADDED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.ADD_NEW_ACTIVITY)
        {
            System.out.println("Received command: " + command);
            try {
                FacturaInfo facturaInfo = (FacturaInfo) in.readObject();
                System.out.println(facturaInfo);
                boolean success = repository.addNewActivity(facturaInfo);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.NEW_ACTIVITY_ADDED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.UPDATE_PRODUCT)
        {
            System.out.println("Received command: " + command);
            try {
                Product product = (Product)in.readObject();
                System.out.println(product);
                boolean success = repository.updateProduct(product);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.PRODUCT_UPDATED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.UPDATE_CLIENT)
        {
            System.out.println("Received command: " + command);
            try {
                Client client = (Client) in.readObject();
                System.out.println(client);
                boolean success = repository.updateClient(client);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.CLIENT_UPDATED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.UPDATE_SELLER)
        {
            System.out.println("Received command: " + command);
            try {
                Seller seller = (Seller) in.readObject();
                System.out.println(seller);
                boolean success = repository.updateSeller(seller);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.SELLER_UPDATED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.UPDATE_EMITOR)
        {
            System.out.println("Received command: " + command);
            try {
                Emitor emitor = (Emitor) in.readObject();
                System.out.println(emitor);
                boolean success = repository.updateEmitor(emitor);
                out.writeObject(true);
                out.flush();
                server.notifyAllClients(Notifications.EMITOR_UPDATED + " by " + clientName,this);

            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.UPDATE_ACTIVITY)
        {
            System.out.println("Received command: " + command);
            try {
                FacturaInfo facturaInfo = (FacturaInfo) in.readObject();
                System.out.println(facturaInfo);
                boolean success = repository.updateActivity(facturaInfo);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.ACTIVITY_UPDATED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.DELETE_PRODUCT)
        {
            System.out.println("Received command: " + command);
            try {
                Product product = (Product)in.readObject();
                System.out.println(product);
                boolean success = repository.deleteProduct(product);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.PRODUCT_DELETED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.DELETE_CLIENT)
        {
            System.out.println("Received command: " + command);
            try {
                Client client = (Client) in.readObject();
                System.out.println(client);
                boolean success = repository.deleteClient(client);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.CLIENT_DElETED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.DELETE_SELLER)
        {
            System.out.println("Received command: " + command);
            try {
                Seller seller = (Seller) in.readObject();
                System.out.println(seller);
                boolean success = repository.deleteSeller(seller);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.SELLER_DELETED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.DELETE_EMITOR)
        {
            System.out.println("Received command: " + command);
            try {
                Emitor emitor = (Emitor) in.readObject();
                System.out.println(emitor);
                boolean success = repository.deleteEmitor(emitor);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.EMITOR_DELETED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.DELETE_ACTIVITY)
        {
            System.out.println("Received command: " + command);
            try {
                FacturaInfo facturaInfo = (FacturaInfo) in.readObject();
                System.out.println(facturaInfo);
                boolean success = repository.deleteActivity(facturaInfo);
                out.writeObject(true);
                out.flush();

                server.notifyAllClients(Notifications.ACTIVITY_DELETED + " by " + clientName,this);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.writeObject(false);
                out.flush();
            } catch (Exception e)
            {
                out.writeObject(false);
                out.flush();
            }
        }
        else if(command == ServerCommands.COMMAND.GENERATE_INVOICE)
        {
            System.out.println("Received command: " + command);
            try {

                Factura factura = (Factura)in.readObject();
                pdfCreator.createPdf("a4",factura);

                InvoicesAvailable invoicesAvailable = (InvoicesAvailable)in.readObject();
                repository.updateBatch(invoicesAvailable);

                server.notifyAllClients(Notifications.NEW_INVOICE_CREATED + " by " + clientName,this);
                new Thread(() -> this.sendMail(factura)).start();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
        else if (command == ServerCommands.COMMAND.INVALID_COMMAND)
        {
            System.out.println("Received command: " + command);
        }
    }

    public void sendNotification(String message)
    {
        try {
            nout.writeObject(message);
            nout.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void sendMail(Factura factura)
    {

        System.out.println("----------EMAIL-----------------------");
        final String username = "mat.gabi7@gmail.com";
        final String password = "";

        System.out.println(factura.getName());

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props,
                new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(username, password);
                    }
                });

        try {

            Message message = new MimeMessage(session);


            InternetAddress me = new InternetAddress("mat.gabi7@gmail.com");
            me.setPersonal("Invoice System - PS");
            message.setFrom(new InternetAddress(me.toString()));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse("mat.gabi@yahoo.com"));

            message.setSubject("New invoice");

            String messageText = String.format("A new invoices was created\n\n" +
                    "Date : " + new Date() + "\n" +
                    "Client : " + factura.getClient().getName() + "\n" +
                    "Factura : " + factura.getName() + "\n" +
                    "Emitor : " + factura.getSeller().getName() + "\n" +
                    "Persoana de contact : " + factura.getEmitor().getFirstName()
            );

            BodyPart bodyPart  = new MimeBodyPart();
            bodyPart.setText(messageText);

            MimeBodyPart mimeBodyPart = new MimeBodyPart();
            String file = factura.getPdfPath() + "\\" + factura.getName() + ".pdf";
            javax.activation.DataSource source = new FileDataSource(file);
            mimeBodyPart.setDataHandler(new DataHandler(source));
            mimeBodyPart.setFileName(factura.getName() + ".pdf");

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(bodyPart);
            multipart.addBodyPart(mimeBodyPart);

            message.setContent(multipart);

            Transport.send(message);

            System.out.println("Done - EMAIL WAS SUCCESSFULLY SENT");

        } catch (MessagingException e) {
            throw new RuntimeException(e);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private void closeAll() {
        isStopped = true;
        server.removeClient(this);
        server.close();
        try {
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void close() {
        isStopped = true;
        server.removeClient(this);
        try {
            in.close();
            out.close();
            nin.close();
            nout.close();

            socket.close();
            notifications.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
