using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Client
{
    public partial class FormLogin : Form
    {
        private string connectionString = String.Format("Server = localhost; Port=5432; Database = railway_directory;");
        private NpgsqlConnection _connection;
        public string username;
        private NpgsqlCommand _command;

        public FormLogin()
        {
            InitializeComponent();
        }

        private void buttonLogin_Click(object sender, EventArgs e)
        {
            string _username = tbUsername.Text.Trim().ToLower();
            string _password = tbPassword.Text;
            string _usernamepass = String.Format("User ID = {0}; Password = {1}", _username, _password);

            if (_usernamepass == "" || _password == "")
            {
                MessageBox.Show("имя пользователя и пароль не могут быть пустыми!");
            }
            else
            {
                _connection = new NpgsqlConnection(connectionString + _usernamepass);
                _connection.Open();
                _command = new NpgsqlCommand();
                _command.Connection = _connection;
                _command.CommandType = System.Data.CommandType.Text;
                username = _username;

                this.Hide();
                FormMain fm = new FormMain(_connection, _command, username);
                fm.Show();
                return;
            }
        }
    }
}